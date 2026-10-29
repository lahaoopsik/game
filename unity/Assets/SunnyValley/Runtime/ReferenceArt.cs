using System.Collections.Generic;
using UnityEngine;
namespace SunnyValley {
 public static class ReferenceArt {
  static readonly Dictionary<string,Sprite> Cache=new Dictionary<string,Sprite>();
  public static Sprite Region(string name,Rect topRect){string key=name+topRect;if(Cache.TryGetValue(key,out var found))return found;var tex=Resources.Load<Texture2D>("Art/"+name);if(!tex)throw new System.Exception("Missing art "+name);tex.filterMode=FilterMode.Point;var r=new Rect(Mathf.Round(topRect.x*tex.width),Mathf.Round((1-topRect.y-topRect.height)*tex.height),Mathf.Round(topRect.width*tex.width),Mathf.Round(topRect.height*tex.height));r.width=Mathf.Min(r.width,tex.width-r.x);r.height=Mathf.Min(r.height,tex.height-r.y);var s=Sprite.Create(tex,r,new Vector2(.5f,0),100,0,SpriteMeshType.FullRect);Cache[key]=s;return s;}
  public static Sprite Full(string name)=>Region(name,new Rect(0,0,1,1));
  public static Sprite Frame(string name,int x,int y,int cols,int rows)=>Region(name,new Rect(x/(float)cols,y/(float)rows,1f/cols,1f/rows));
  public static Sprite Tree(int id)=>Frame("nature-v2",id%4,0,4,4);
  public static Sprite Tent(int variant)=>Frame("village-v2",variant%4,0,4,4);
  public static Vector2 PropSize(string f,int v){if(f=="flower")return new Vector2(30,40);if(f=="stump")return new Vector2(44,38);if(f=="deposit")return new Vector2(62,54);if(f=="crop")return new Vector2(40,46);if(f=="bench")return new Vector2(96,80);if(f=="lamp")return v==0?new Vector2(64,120):new Vector2(64,88);if(f=="torch")return new Vector2(24,80);if(f=="fence")return new Vector2(96,60);if(f=="camp")return new[]{new Vector2(56,56),new Vector2(72,64),new Vector2(96,60),new Vector2(56,72)}[v-4];int[,] sizes={{16,18},{16,14},{16,16},{20,12},{24,16},{20,20},{24,28},{28,20},{20,12},{28,16},{16,12},{24,18},{16,28},{20,12},{14,18},{16,26}};return new Vector2(sizes[v,0]*2,sizes[v,1]*2);}
  public static Sprite Prop(string family,int v,int turn=0,int frame=0){
   if(family=="flower")return Frame("flowers-stumps-v1",v%4,(v/4)%2,4,4);
   if(family=="stump")return Frame("flowers-stumps-v1",v%4,2+(v/4)%2,4,4);
   if(family=="deposit")return Frame("nature-v2",v%4,2,4,4);
   if(family=="crop")return Frame("crops-v2",v%4,(v/4)%4,4,4);
   if(family=="bench")return Frame("village-v2",2,2,4,4);
   if(family=="lamp")return Frame("village-v2",1,2,4,4);
   if(family=="torch")return Frame("village-v2",1,2,4,4);
   if(family=="fence")return Frame("village-v2",(turn+v)%4,1,4,4);
   if(family=="camp"){if(v==4)return Frame("village-v2",0,2,4,4);if(v==5)return Frame("village-v2",1,2,4,4);if(v==6)return Frame("village-v2",3,2,4,4);return Frame("nature-v2",(v-7)%4,1,4,4);}
   if(v<4)return Frame("nature-v2",v,3,4,4);if(v<8)return Frame("village-v2",v-4,2,4,4);if(v>13)return Frame("nature-v2",v-14,2,4,4);return Frame("nature-v2",(v-8)%4,1,4,4);
  }
 }
 public class SpriteView {
  public GameObject go;public SpriteRenderer renderer;public Vector2 position,size;public float hit;
  public SpriteView(Transform parent,string name,Sprite sprite,Vector2 p,Vector2 dimensions,int order=0){go=new GameObject(name);go.transform.SetParent(parent,false);renderer=go.AddComponent<SpriteRenderer>();renderer.sharedMaterial=ValleyGame.WorldMaterial;Set(sprite,dimensions);Place(p,order);}
  public void Set(Sprite sprite,Vector2 dimensions){renderer.sprite=sprite;size=dimensions;go.transform.localScale=new Vector3(dimensions.x/100/sprite.bounds.size.x,dimensions.y/100/sprite.bounds.size.y,1);}
  public void Place(Vector2 p,int order=0){position=p;go.transform.position=new Vector3(p.x/100,-p.y/100,0);renderer.sortingOrder=order==0?Mathf.RoundToInt(p.y):order;}
  public void Destroy(){Object.Destroy(go);}
 }
}
