using System;
using System.Collections.Generic;
using UnityEngine;
namespace SunnyValley {
 public static class StarterGenerator {
  public const int Version=1;
  struct Basin {public Vector2 center,radius;public Basin(Vector2 c,Vector2 r){center=c;radius=r;}}
  public static WorldData Generate(int seed,WorldData template){for(int attempt=0;attempt<8;attempt++){var world=Build(seed,seed+attempt*8191,template);if(Validate(world,out _))return world;}throw new Exception("Starter world failed validation; no invalid world accepted");}
  static bool Protected(Vector2 p)=>Vector2.Distance(p,new Vector2(25,18))<8||Vector2.Distance(p,new Vector2(44,44))<11;
  static float Segment(Vector2 p,Vector2 a,Vector2 b){Vector2 d=b-a;float t=Mathf.Clamp01(Vector2.Dot(p-a,d)/d.sqrMagnitude);return Vector2.Distance(p,a+d*t);}
  static bool Route(Vector2 p)=>Segment(p,new Vector2(25,18),new Vector2(34,27))<2.5f||Segment(p,new Vector2(34,27),new Vector2(44,44))<2.5f||Segment(p,new Vector2(25,18),new Vector2(9,22))<2.5f;
  static WorldData Build(int publicSeed,int seed,WorldData template){
   var rng=new System.Random(seed);float ox=rng.Next(1000,9000),oy=rng.Next(1000,9000);var w=new WorldData{width=87,height=65,seed=publicSeed,generatorVersion=Version,cells=new Cell[87*65],bridge=new Position(template.bridge.V),tents=JsonUtility.FromJson<WorldData>(JsonUtility.ToJson(template)).tents};
   var basins=new List<Basin>();
   // One landmark lake; a handful of ponds with explicit spacing and route buffers.
   var lakeCenter=new Vector2(rng.Next(59,72),rng.Next(27,39));basins.Add(new Basin(lakeCenter,new Vector2(rng.Next(5,8),rng.Next(4,6))));
   int wanted=rng.Next(2,5);for(int tries=0;tries<250&&basins.Count<wanted+1;tries++){var c=new Vector2(rng.Next(20,80),rng.Next(8,59));var r=new Vector2(rng.Next(2,4),rng.Next(2,4));if(Protected(c)||Route(c)||Vector2.Distance(c,new Vector2(25,18))<12||Vector2.Distance(c,new Vector2(44,44))<16)continue;bool clear=true;foreach(var b in basins)if(Vector2.Distance(c,b.center)<b.radius.magnitude+r.magnitude+7)clear=false;if(clear)basins.Add(new Basin(c,r));}
   foreach(var b in basins){if(b.radius.x>4)w.lake=new Position(b.center*48+Vector2.one*24);}w.basinCount=basins.Count;
   for(int y=0;y<65;y++)for(int x=0;x<87;x++){
    Vector2 p=new Vector2(x+.5f,y+.5f);float broad=Mathf.PerlinNoise(ox+x*.045f,oy+y*.045f);int kind=0,height=0;float riverCenter=template.bridge.x/48+Mathf.Sin((y-template.bridge.y/48)*.12f)*1.4f;bool water=Mathf.Abs(x+.5f-riverCenter)<1.15f;
    foreach(var b in basins){Vector2 q=(p-b.center)/b.radius;float rim=1+(Mathf.PerlinNoise(ox+x*.24f,oy+y*.24f)-.5f)*.18f;if(q.sqrMagnitude<rim)water=true;else if(q.sqrMagnitude<rim*1.35f)kind=1;}
    if(!water){float bank=Mathf.Abs(x+.5f-riverCenter);if(bank<2.25f)kind=1;else if(broad>.7f)kind=3;else if(broad<.25f)kind=2;if((y<3+broad*4||x>81+broad*3)&&!Protected(p)){height=1;kind=5;}if(broad>.72f&&y<17&&!Protected(p)&&!Route(p)){height=1;kind=5;}}
    if(water){kind=7;height=0;}if(Protected(p)){kind=0;height=0;}if(Route(p)&&!water){kind=3;height=0;}
    // Village is a reserved designed scene; floor stays dry and spacious.
    if(Vector2.Distance(p,new Vector2(44,44))<7)kind=3;
    w.cells[y*87+x]=new Cell{x=x,y=y,kind=kind,height=height,ramp=Route(p)};
   }
   var cropPlots=new[]{new RectInt(36,47,4,3),new RectInt(42,48,3,2)};var crops=new List<PropData>();
   foreach(var field in cropPlots)for(int fy=field.y;fy<field.yMax;fy++)for(int fx=field.x;fx<field.xMax;fx++){var bed=w.cells[fy*87+fx];bed.kind=4;bed.height=0;bed.wet=fy>field.y;int crop=field.x<40?fy-field.y:3;int stage=(fx-field.x)%4;crops.Add(new PropData{id="crop:"+fx+":"+fy,family="crop",variant=crop*4+stage,x=fx*48+24,y=fy*48+24});}
   var trees=new List<TreeData>();var grass=new List<GrassData>();
   for(int y=4;y<61;y++)for(int x=16;x<81;x++){
    var cell=w.cells[y*87+x];Vector2 p=new Vector2(x+.5f,y+.5f);if(TerrainRules.Plane(cell)!=TerrainPlane.Floor||cell.kind!=0||Route(p)||Protected(p))continue;
    float grove=Mathf.PerlinNoise(ox+x*.085f,oy+y*.085f);if(grove>.47f&&rng.NextDouble()<.12){Vector2 pos=p*48+new Vector2(rng.Next(-9,10),rng.Next(-9,10));bool clear=true;foreach(var t in trees)if(Vector2.Distance(pos,new Vector2(t.x,t.y))<85){clear=false;break;}if(clear)trees.Add(new TreeData{id=10000+y*87+x,x=pos.x,y=pos.y,hp=3});}
    if((x+y)%2==0&&rng.NextDouble()<.7)grass.Add(new GrassData{id="g1:"+x+":"+y,x=x*48+rng.Next(10,39),y=y*48+rng.Next(10,39),variant=rng.Next(4)});
   }
   // A few nearby trees are guaranteed for a fair resource start.
   foreach(var offset in new[]{new Vector2(-6,-2),new Vector2(6,-3),new Vector2(-5,5),new Vector2(6,5)}){Vector2 c=new Vector2(25,18)+offset;int x=(int)c.x,y=(int)c.y;var cell=w.cells[y*87+x];if(cell.kind!=7&&TerrainRules.Plane(cell)==TerrainPlane.Floor)trees.Add(new TreeData{id=20000+y*87+x,x=x*48+24,y=y*48+24,hp=3});}
   if(w.lake!=null){int lx=(int)(w.lake.x/48),ly=(int)(w.lake.y/48);while(ly>1&&w.cells[(ly-1)*87+lx].kind==7)ly--;int tx=lx+1,ty=ly-1;if(w.cells[ty*87+tx].kind!=7)trees.Add(new TreeData{id=30000+ty*87+tx,x=tx*48+24,y=ty*48+24,hp=3});}
   w.trees=trees.ToArray();w.grass=grass.ToArray();w.crops=crops.ToArray();var scenery=new List<PropData>();int flowerId=0;
   // Flower patches follow basin shores, leaving paths and the goblin camp clear.
   foreach(var b in basins)for(int n=0;n<8;n+=2){float a=(n+.35f)*Mathf.PI/4;int cx=Mathf.RoundToInt(b.center.x+Mathf.Cos(a)*(b.radius.x+1.5f)),cy=Mathf.RoundToInt(b.center.y+Mathf.Sin(a)*(b.radius.y+1.5f));for(int radius=0;radius<3;radius++){bool placed=false;for(int dy=-radius;dy<=radius&&!placed;dy++)for(int dx=-radius;dx<=radius&&!placed;dx++){int x=cx+dx,y=cy+dy;if(x<1||x>=86||y<1||y>=64)continue;var c=w.cells[y*87+x];Vector2 p=new Vector2(x+.5f,y+.5f);if(c.kind!=0||TerrainRules.Plane(c)!=TerrainPlane.Floor||Route(p)||Protected(p))continue;scenery.Add(new PropData{id="flower:"+(flowerId++),family="flower",variant=rng.Next(8),x=x*48+24+rng.Next(-7,8),y=y*48+24+rng.Next(-7,8)});placed=true;}}}
   // Old stumps sit in small clearings among mature forest, not on routes or crop beds.
   int stumpId=0;for(int y=6;y<60&&stumpId<10;y+=2)for(int x=14;x<80&&stumpId<10;x+=2){Vector2 p=new Vector2(x+.5f,y+.5f);var c=w.cells[y*87+x];if(c.kind!=0||TerrainRules.Plane(c)!=TerrainPlane.Floor||Protected(p)||Route(p)||Mathf.PerlinNoise(ox+x*.085f,oy+y*.085f)<.54f||rng.NextDouble()>.16)continue;bool clear=true;foreach(var t in trees)if(Vector2.Distance(p*48,new Vector2(t.x,t.y))<74){clear=false;break;}if(clear){scenery.Add(new PropData{id="stump:"+(stumpId++),family="stump",variant=rng.Next(8),x=x*48+24,y=y*48+24});x+=2;}}
   // Mineable stone and ore nodes sit on gravel shelves near natural ridges.
   int nodeId=0;var nodes=new List<Vector2>();for(int y=6;y<60&&nodeId<16;y+=2)for(int x=8;x<80&&nodeId<16;x+=2){var c=w.cells[y*87+x];Vector2 p=new Vector2(x+.5f,y+.5f);if(c.kind!=2||TerrainRules.Plane(c)!=TerrainPlane.Floor||Protected(p)||Route(p)||rng.NextDouble()>.13)continue;bool shelf=false;for(int dy=-2;dy<=2&&!shelf;dy++)for(int dx=-2;dx<=2;dx++){int xx=x+dx,yy=y+dy;if(xx>=0&&xx<87&&yy>=0&&yy<65&&w.cells[yy*87+xx].height>0){shelf=true;break;}}if(!shelf)continue;bool apart=true;foreach(var q in nodes)if(Vector2.Distance(p*48,q)<160){apart=false;break;}if(!apart)continue;nodes.Add(p*48);int roll=rng.Next(100),kind=roll<54?0:roll<80?1:roll<95?2:3;scenery.Add(new PropData{id="deposit:"+(nodeId++),family="deposit",variant=kind,x=x*48+24,y=y*48+24});}
   w.scenery=scenery.ToArray();
   var props=new List<PropData>();foreach(var d in JsonUtility.FromJson<WorldData>(JsonUtility.ToJson(template)).decorations){if(d.location!="outside"){props.Add(d);continue;}int x=Mathf.FloorToInt(d.x/48),y=Mathf.FloorToInt(d.y/48);if(x<0||x>=87||y<0||y>=65)continue;var c=w.cells[y*87+x];if(TerrainRules.Plane(c)==TerrainPlane.Floor)props.Add(d);}if(w.lake!=null){int lx=(int)(w.lake.x/48),ly=(int)(w.lake.y/48);while(ly>1&&w.cells[(ly-1)*87+lx].kind==7)ly--;int px=lx-1,py=ly-1;if(TerrainRules.Plane(w.cells[py*87+px])==TerrainPlane.Floor)props.Add(new PropData{id="lake-lookout",family="lamp",variant=0,x=px*48+24,y=py*48+24,location="outside"});}w.decorations=props.ToArray();return w;
  }
  public static bool Validate(WorldData w,out string reason){reason="";if(w.cells==null||w.cells.Length!=w.width*w.height){reason="shape";return false;}var reached=new bool[w.cells.Length];var queue=new Queue<int>();int start=18*w.width+25;queue.Enqueue(start);reached[start]=true;int floors=0,walked=0,water=0;
   foreach(var c in w.cells){if(c.kind==7)water++;if(TerrainRules.Plane(c)==TerrainPlane.Floor)floors++;}
   while(queue.Count>0){int i=queue.Dequeue();var c=w.cells[i];if(c.kind!=7)walked++;foreach(int d in new[]{-1,1,-w.width,w.width}){int n=i+d;if(n<0||n>=w.cells.Length||Mathf.Abs(w.cells[n].x-c.x)+Mathf.Abs(w.cells[n].y-c.y)!=1||reached[n])continue;var next=w.cells[n];Vector2 p=new Vector2(next.x*48+24,next.y*48+24);bool bridge=Mathf.Abs(p.x-w.bridge.x)<120&&Mathf.Abs(p.y-w.bridge.y)<38;if(!TerrainRules.Walkable(next,bridge))continue;reached[n]=true;queue.Enqueue(n);}}
   if(!reached[44*w.width+44]||walked<floors*.96f){reason="routes";return false;}float ratio=water/(float)w.cells.Length;if(ratio<.035f||ratio>.14f){reason="water coverage";return false;}if(w.basinCount<3||w.basinCount>5){reason="basins";return false;}if(w.trees.Length<35){reason="trees";return false;}return true;
  }
 }
}
