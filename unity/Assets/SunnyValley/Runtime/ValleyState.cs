using System;
using System.Collections.Generic;
using UnityEngine;
namespace SunnyValley {
 [Serializable] public class Cell {public int x,y,kind,height; public bool ramp,wet;}
 [Serializable] public class TreeData {public int id,hp; public float x,y;}
 [Serializable] public class GrassData {public string id; public int variant; public float x,y;}
 [Serializable] public class PropData {public string id,family,location="outside";public int variant,rotation;public float x,y;}
 [Serializable] public class TentData {public int variant;public float x,y;}
 [Serializable] public class Position {public float x,y; public Vector2 V=>new Vector2(x,y);public Position(){} public Position(Vector2 v){x=v.x;y=v.y;}}
 [Serializable] public class WorldData {public int width,height,seed,generatorVersion,basinCount;public Position lake;public Cell[] cells;public TreeData[] trees;public GrassData[] grass;public PropData[] decorations,scenery,crops;public TentData[] tents;public Position bridge;}
 [Serializable] public class Stack {public string item;public int count;public Stack(string i,int n){item=i;count=n;}}
 [Serializable] public class Inventory {
  public Stack[] hotbar=new Stack[9],pocket=new Stack[6];
  static bool Has(Stack s)=>s!=null&&!string.IsNullOrEmpty(s.item)&&s.count>0;
  public int Count(string item){int n=0;foreach(var a in new[]{hotbar,pocket})foreach(var s in a)if(Has(s)&&s.item==item)n+=s.count;return n;}
  public bool Add(string item,int amount){if(amount<=0)return false;foreach(var a in new[]{hotbar,pocket})foreach(var s in a)if(Has(s)&&s.item==item){s.count+=amount;return true;}foreach(var a in new[]{hotbar,pocket})for(int i=0;i<a.Length;i++)if(!Has(a[i])){a[i]=new Stack(item,amount);return true;}return false;}
  public bool Remove(string item,int amount){if(amount<0||Count(item)<amount)return false;foreach(var a in new[]{hotbar,pocket})for(int i=0;i<a.Length;i++){var s=a[i];if(!Has(s)||s.item!=item)continue;int n=Math.Min(amount,s.count);s.count-=n;amount-=n;if(s.count==0)a[i]=null;}return true;}
  public bool Move(bool sourcePocket,int source,bool targetPocket,int target){var a=sourcePocket?pocket:hotbar;var b=targetPocket?pocket:hotbar;if(source<0||source>=a.Length||target<0||target>=b.Length||!Has(a[source])||(a==b&&source==target))return false;var s=a[source];var d=b[target];if(Has(d)&&d.item==s.item){d.count+=s.count;a[source]=null;}else{b[target]=s;a[source]=Has(d)?d:null;}return true;}
  public bool Valid(){if(hotbar==null||hotbar.Length!=9||pocket==null||pocket.Length!=6)return false;foreach(var a in new[]{hotbar,pocket})foreach(var s in a)if(s!=null&&!Has(s)&&!(s.count==0&&string.IsNullOrEmpty(s.item)))return false;return true;}
 }
 [Serializable] public class Building {public int id,wood,work,rotation;public float x,y;public string location="outside";}
 [Serializable] public class SaveData {
  public int version=3,seed=2317,generatorVersion=1,nextId=1000,day=1;public float phase=.32f;public Position player=new Position(new Vector2(1200,900)),outside=new Position(new Vector2(2120,1920));
  public string location="outside";public Inventory inventory=new Inventory();public List<TreeData> trees=new List<TreeData>();public List<PropData> decorations=new List<PropData>();public List<Building> buildings=new List<Building>();public List<string> clearedGrass=new List<string>();
 }
 public class ValleyState {
  public readonly WorldData World;public SaveData Save;public string Room=>Save.location;
  public ValleyState(WorldData world){World=world;Save=new SaveData{seed=world.seed,generatorVersion=world.generatorVersion};Save.trees.AddRange(JsonUtility.FromJson<WorldData>(JsonUtility.ToJson(world)).trees);Save.decorations.AddRange(JsonUtility.FromJson<WorldData>(JsonUtility.ToJson(world)).decorations);}
  public Cell CellAt(Vector2 p){int x=Mathf.FloorToInt(p.x/48),y=Mathf.FloorToInt(p.y/48);if(x<0||y<0||x>=World.width||y>=World.height)return null;return World.cells[y*World.width+x];}
  public bool Bridge(Vector2 p)=>Mathf.Abs(p.x-World.bridge.x)<120&&Mathf.Abs(p.y-World.bridge.y)<38;
  public static bool Portable(string family,int variant)=>family=="micro"?variant>=0&&variant<16&&(variant<8||variant>13):family=="flower"||family=="stump"||family=="deposit"||family=="bench"||family=="torch"||family=="lamp"||family=="fence"||(family=="camp"&&variant>=4&&variant<=7);
  public bool Walkable(Vector2 from,Vector2 p){
   if(Room!="outside"){Vector2 q=(p-new Vector2(480,330))/new Vector2(410,250);return q.sqrMagnitude<1||(Mathf.Abs(p.x-480)<45&&p.y>520&&p.y<610);}
   var a=CellAt(from);var b=CellAt(p);if(a==null||b==null||p.x<20||p.y<20||p.x>4156||p.y>3100)return false;if(!TerrainRules.Walkable(b,Bridge(p)))return false;
   foreach(var t in Save.trees)if(Vector2.Distance(p,new Vector2(t.x,t.y))<26)return false;
   foreach(var t in World.tents){var r=new Rect(t.x-(t.variant==0?90:48),t.y-60,t.variant==0?180:96,60);if(r.Contains(p))return false;}
   foreach(var d in Save.decorations){if(d.location!=Room)continue;Vector2 q=p-new Vector2(d.x,d.y);if(d.family=="fence"&&Mathf.Abs(q.x)<((d.rotation+d.variant)%2==0?48:18)&&Mathf.Abs(q.y)<((d.rotation+d.variant)%2==0?16:30))return false;}
   foreach(var d in Save.buildings)if(d.location==Room&&d.work>=4&&Vector2.Distance(p,new Vector2(d.x,d.y))<40)return false;
   return true;
  }
  public bool CanPlace(Vector2 actor,Vector2 p){if(Vector2.Distance(actor,p)>210||Vector2.Distance(actor,p)<36||!Walkable(actor,p))return false;if(Room=="outside"&&Bridge(p))return false;foreach(var d in Save.decorations)if(d.location==Room&&Vector2.Distance(p,new Vector2(d.x,d.y))<38)return false;foreach(var b in Save.buildings)if(b.location==Room&&Vector2.Distance(p,new Vector2(b.x,b.y))<90)return false;return true;}
  // All resource and world mutations enter through this command boundary.
  public string Command(string action,Vector2 actor,Vector2 target,string item="",int rotation=0){
   if(action=="chop"){
    for(int i=0;i<Save.decorations.Count;i++){var d=Save.decorations[i];if(d.location!=Room||!Portable(d.family,d.variant)||Vector2.Distance(target,new Vector2(d.x,d.y))>24||Vector2.Distance(actor,new Vector2(d.x,d.y))>110)continue;if(!Save.inventory.Add("prop:"+d.family+":"+d.variant,1))return "Нет места";Save.decorations.RemoveAt(i);return "Предмет разобран";}
    if(Room!="outside")return "Здесь нечего разбирать";
    for(int i=0;i<Save.trees.Count;i++){var t=Save.trees[i];Vector2 p=new Vector2(t.x,t.y);if(Vector2.Distance(actor,p)>110||Vector2.Distance(target,p)>65)continue;t.hp--;if(t.hp<=0){if(!Save.inventory.Add("wood",5)){t.hp=1;return "Нет места";}Save.trees.RemoveAt(i);return "+5 древесины";}return "Удар · осталось "+t.hp;}
    if(World.scenery!=null)foreach(var d in World.scenery){if(d.location!=Room||Save.clearedGrass.Contains(d.id)||Vector2.Distance(actor,new Vector2(d.x,d.y))>110||Vector2.Distance(target,new Vector2(d.x,d.y))>24)continue;string resource=d.family=="deposit"?new[]{"stone","iron","coal","crystal"}[Mathf.Clamp(d.variant,0,3)]:"prop:"+d.family+":"+d.variant;if(!Save.inventory.Add(resource,1))return "Нет места";Save.clearedGrass.Add(d.id);return d.family=="stump"?"Пень убран":d.family=="flower"?"Цветок собран":"Ресурс добыт";}
    foreach(var g in World.grass)if(!Save.clearedGrass.Contains(g.id)&&Vector2.Distance(actor,new Vector2(g.x,g.y))<110&&Vector2.Distance(target,new Vector2(g.x,g.y))<24){Save.clearedGrass.Add(g.id);return "Трава срезана";}
    return "Подойди ближе";
   }
   if(action=="interact"){foreach(var b in Save.buildings){if(b.location!=Room||Vector2.Distance(actor,new Vector2(b.x,b.y))>110||Vector2.Distance(target,new Vector2(b.x,b.y))>70)continue;if(b.wood<12){int n=Math.Min(12-b.wood,Save.inventory.Count("wood"));Save.inventory.Remove("wood",n);b.wood+=n;return "Дерево: "+b.wood+"/12";}if(b.work<4)b.work++;return b.work>=4?"Верстак построен":"Работа: "+b.work+"/4";}return "Подойди к чертежу";}
   Vector2 snapped=new Vector2(Mathf.Floor(target.x/48)*48+24,Mathf.Floor(target.y/48)*48+24);
   if(action=="place"){if(!CanPlace(actor,snapped))return "Здесь нельзя строить";Save.buildings.Add(new Building{id=Save.nextId++,x=snapped.x,y=snapped.y,rotation=rotation,location=Room});return "Чертёж размещён";}
   if(action=="place_decor"){string[] parts=item.Split(':');if(parts.Length!=3||!int.TryParse(parts[2],out int v)||!Portable(parts[1],v)||!CanPlace(actor,snapped)||!Save.inventory.Remove(item,1))return "Предмет не помещается";Save.decorations.Add(new PropData{id="unity:"+Save.nextId++,family=parts[1],variant=v,x=snapped.x,y=snapped.y,rotation=rotation,location=Room});return "Предмет установлен";}
   return "";
  }
  public bool Restore(string json){if(string.IsNullOrEmpty(json)||!json.Contains("\"version\""))return false;SaveData data;try{data=JsonUtility.FromJson<SaveData>(json);}catch{return false;}if(data==null||data.version!=3||data.seed!=World.seed||data.generatorVersion!=World.generatorVersion||data.inventory==null||!data.inventory.Valid()||data.trees==null||data.decorations==null||data.buildings==null||data.clearedGrass==null||data.player==null||data.outside==null||(data.location!="outside"&&data.location!="chief_tent"))return false;foreach(var t in data.trees)if(t.hp<1||t.hp>3)return false;Save=data;return true;}
 }
}
