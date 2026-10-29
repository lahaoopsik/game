using System.Collections.Generic;
using UnityEngine;
namespace SunnyValley {
 public static class BlockArt {
  static readonly Dictionary<string,Sprite> sprites=new Dictionary<string,Sprite>();
  static Sprite Rect(string name,int x,int y,int w,int h){string key=name+":"+x+":"+y;if(sprites.TryGetValue(key,out var s))return s;var t=Resources.Load<Texture2D>("Blocks/"+name);t.filterMode=FilterMode.Point;s=Sprite.Create(t,new Rect(x,t.height-y-h,w,h),new Vector2(.5f,0),100,0,SpriteMeshType.FullRect);sprites[key]=s;return s;}
  public static Sprite Floor(int kind,int v)=>Rect("floors",v*24,kind*24,24,24);
  public static Sprite Wall(int material,int v,bool face)=>Rect("walls",v*24,material*40+(face?24:0),24,face?16:24);
  public static Sprite Rim(int v)=>Rect("grass-edge",v*24,0,24,8);
  public static void InstallMap(WorldData data){var t=new Texture2D(data.width,data.height,TextureFormat.RGBA32,false,true);t.filterMode=FilterMode.Point;t.wrapMode=TextureWrapMode.Clamp;var p=new Color32[data.width*data.height];foreach(var c in data.cells)p[(data.height-c.y-1)*data.width+c.x]=new Color32((byte)(c.kind==7?255:0),0,0,255);t.SetPixels32(p);t.Apply();Shader.SetGlobalTexture("_ValleyTerrainMap",t);Shader.SetGlobalVector("_ValleyMapSize",new Vector4(data.width*48,data.height*48,data.width,data.height));}
 }
 public class WaterReflections {
  class Reflection {public SpriteView source,view;public Vector2 shore;}
  ValleyGame game;
  readonly List<Reflection> list=new List<Reflection>();readonly Material material;
  public WaterReflections(ValleyGame game,Transform parent,List<SpriteView> sources){this.game=game;if(game.State.Room!="outside")return;material=new Material(Resources.Load<Shader>("Shaders/WaterReflection"));var layer=new GameObject("04 Reflections clipped to water").transform;layer.SetParent(parent,false);
   foreach(var source in sources){if(source.renderer.sortingOrder<0||source.go.name=="Grass"||source.go.name.StartsWith("Grass "))continue;Vector2 p=source.position;Cell nearest=null;float best=180*180;for(int y=-1;y<=4;y++)for(int x=-2;x<=2;x++){var c=game.State.CellAt(p+new Vector2(x*48,y*48));if(c==null||c.kind!=7)continue;Vector2 bank=new Vector2(c.x*48+24,c.y*48);float distance=(bank-p).sqrMagnitude;if(bank.y>=p.y-8&&distance<best){nearest=c;best=distance;}}if(nearest==null&&source.go.name!="Player"&&source.go.name!="Resident")continue;var anchor=new Vector2(p.x,nearest==null?p.y+16:nearest.y*48+16);var v=new SpriteView(layer,"Water reflection",source.renderer.sprite,anchor,source.size,-11000);v.renderer.sharedMaterial=material;v.renderer.flipY=true;list.Add(new Reflection{source=source,view=v,shore=anchor});}
  }
  public void Dispose(){if(material)Object.Destroy(material);}
  public void Tick(){foreach(var r in list){if(!r.source.go)continue;if(r.source.go.name=="Player"||r.source.go.name=="Resident"){Vector2 p=r.source.position;Cell bank=null;for(int dy=0;dy<4;dy++){var c=game.State.CellAt(p+new Vector2(0,dy*48));if(c!=null&&c.kind==7){bank=c;break;}}if(bank==null){r.view.renderer.enabled=false;continue;}r.shore=new Vector2(p.x,bank.y*48+16);}r.view.Set(r.source.renderer.sprite,r.source.size);r.view.renderer.flipX=r.source.renderer.flipX;r.view.renderer.enabled=r.source.renderer.enabled;r.view.Place(r.shore,-11000);var block=new MaterialPropertyBlock();block.SetVector("_ReflectAnchor",new Vector4(r.shore.x/100,-r.shore.y/100,r.source.size.y/100,0));r.view.renderer.SetPropertyBlock(block);}}
 }
}
