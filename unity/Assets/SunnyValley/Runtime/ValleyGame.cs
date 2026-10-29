using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
namespace SunnyValley {
 public class ValleyGame:MonoBehaviour {
  public static Material WorldMaterial;ValleyResidents residents;WaterReflections waterReflections;
  int? launchSeed;public bool ReviewMode;public ValleyState State;public Vector2 player;public string Message="Unity · тест переноса";
  public int Selected=-1,Rotation;public bool Backpack,Map,Menu,Blueprint;public Camera Cam;
  public readonly List<SpriteView> Views=new List<SpriteView>();
  Transform landscape,terrainRoot;SpriteView hero,axe;readonly Dictionary<int,SpriteView> trees=new Dictionary<int,SpriteView>();readonly List<KeyValuePair<PropData,SpriteView>> fires=new List<KeyValuePair<PropData,SpriteView>>();
  Vector2 facing=Vector2.down;float swing=2,saveTimer;Vector2 strike;bool impacted=true;Vector2 attackDirection;public Rect Viewport;
  public string SavePath=>Path.GetFullPath(Path.Combine(Application.dataPath,"../../../saves/"+(launchSeed.HasValue?"unity-valley-v3-"+launchSeed.Value+".json":"unity-valley-v3.json")));
  public bool Modal=>Backpack||Map||Menu;public string Item=>Selected>=0&&State.Save.inventory.hotbar[Selected]!=null?State.Save.inventory.hotbar[Selected].item:"";
  [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]static void Boot(){if(!FindFirstObjectByType<ValleyGame>())new GameObject("Sunny Valley Unity").AddComponent<ValleyGame>();}
  void Awake(){var args=System.Environment.GetCommandLineArgs();for(int i=0;i<args.Length-1;i++)if(args[i]=="-seed"&&int.TryParse(args[i+1],out int selectedSeed))launchSeed=selectedSeed;ReviewMode=System.Array.IndexOf(System.Environment.GetCommandLineArgs(),"-valleyCapture")>=0;if(!ReviewMode&&System.Array.IndexOf(args,"-screen-fullscreen")<0)Screen.SetResolution(Screen.currentResolution.width,Screen.currentResolution.height,FullScreenMode.FullScreenWindow);WorldMaterial=new Material(Resources.Load<Shader>("Shaders/LayeredSprite"));Application.targetFrameRate=60;var template=JsonUtility.FromJson<WorldData>(Resources.Load<TextAsset>("Data/world").text);int seed=launchSeed??2317;if(!launchSeed.HasValue&&File.Exists(SavePath)){try{seed=JsonUtility.FromJson<SaveData>(File.ReadAllText(SavePath)).seed;}catch{}}State=new ValleyState(StarterGenerator.Generate(seed,template));player=State.Save.player.V;Cam=Camera.main;if(!Cam){Cam=new GameObject("Main Camera").AddComponent<Camera>();Cam.tag="MainCamera";}Cam.orthographic=true;Cam.orthographicSize=4;Cam.backgroundColor=new Color(.12f,.16f,.16f);Cam.clearFlags=CameraClearFlags.SolidColor;gameObject.AddComponent<ValleyHud>().Game=this;Load(false);Rebuild();}
  public void Rebuild(){waterReflections?.Dispose();if(terrainRoot)terrainRoot.gameObject.SetActive(State.Room=="outside");if(landscape)Destroy(landscape.gameObject);landscape=new GameObject("World visuals").transform;landscape.SetParent(transform);Views.Clear();trees.Clear();fires.Clear();
   bool inside=State.Room!="outside";
   if(inside){Draw("Tent room",ReferenceArt.Full("tent-interior-v1"),new Vector2(480,640),new Vector2(960,640),-10000);}
   else {
    DrawGround();
     Draw("Bridge",ReferenceArt.Full("bridge-v2"),State.World.bridge.V+new Vector2(0,72),new Vector2(288,144),-4000);
    foreach(var t in State.Save.trees)trees[t.id]=Draw("Tree "+t.id,ReferenceArt.Tree(t.id),new Vector2(t.x,t.y+16),new Vector2(128,160));
     foreach(var g in State.World.grass)if(!State.Save.clearedGrass.Contains(g.id)&&TerrainRules.Plane(State.CellAt(new Vector2(g.x,g.y)))==TerrainPlane.Floor)Draw("Grass "+g.id,ReferenceArt.Frame("nature-v2",g.variant%4,3,4,4),new Vector2(g.x,g.y),new Vector2(25,36));
      foreach(var t in State.World.tents)Draw("Goblin tent",ReferenceArt.Tent(t.variant),new Vector2(t.x,t.y+10),t.variant==0?new Vector2(192,160):new Vector2(112,104));
      if(State.World.scenery!=null)foreach(var d in State.World.scenery)if(!State.Save.clearedGrass.Contains(d.id))Draw(d.family,ReferenceArt.Prop(d.family,d.variant),new Vector2(d.x,d.y+4),ReferenceArt.PropSize(d.family,d.variant));
      if(State.World.crops!=null)foreach(var c in State.World.crops)Draw("Garden crop",ReferenceArt.Prop("crop",c.variant),new Vector2(c.x,c.y+6),ReferenceArt.PropSize("crop",c.variant));
   }
   foreach(var d in State.Save.decorations)if(d.location==State.Room){var v=Draw(d.family,ReferenceArt.Prop(d.family,d.variant,d.rotation),new Vector2(d.x,d.y+8),ReferenceArt.PropSize(d.family,d.variant));if(d.family=="camp"&&d.variant==4)fires.Add(new KeyValuePair<PropData,SpriteView>(d,v));}
   ConnectFences();
   foreach(var b in State.Save.buildings)if(b.location==State.Room){var v=Draw("Workbench",ReferenceArt.Prop("bench",0,b.rotation),new Vector2(b.x,b.y+8),ReferenceArt.PropSize("bench",0));if(b.work<4)v.renderer.color=new Color(.6f,1,1,.45f);}
    hero=Draw("Player",ReferenceArt.Frame("hero-v4",0,0,6,4),player,new Vector2(48,64));
    axe=Draw("Summoned axe",ReferenceArt.Frame("axe-v4",0,0,4,4),player,new Vector2(48,56));axe.renderer.enabled=false;residents=new ValleyResidents(this,landscape,Views);waterReflections=new WaterReflections(this,landscape,Views);
  }
  SpriteView Draw(string name,Sprite sprite,Vector2 p,Vector2 size,int order=0){var view=new SpriteView(landscape,name,sprite,p,size,order);Views.Add(view);return view;}
  void DrawGround(){if(terrainRoot)return;terrainRoot=new GameObject("Static terrain planes").transform;terrainRoot.SetParent(transform,false);new LayeredTerrain(State,terrainRoot,new List<SpriteView>()).Build();}
  void ConnectFences(){var ds=State.Save.decorations;foreach(var a in ds){if(a.location!=State.Room||a.family!="fence")continue;foreach(var b in ds){if(b==a||b.location!=a.location||b.family!="fence"||string.CompareOrdinal(a.id,b.id)>=0)continue;Vector2 p=new Vector2(a.x,a.y),q=new Vector2(b.x,b.y),d=q-p;if(d.magnitude>115||Mathf.Min(Mathf.Abs(d.x),Mathf.Abs(d.y))>32)continue;Draw("Fence join",ReferenceArt.Prop("fence",0),Vector2.Lerp(p,q,.5f),new Vector2(Mathf.Abs(d.x)>Mathf.Abs(d.y)?d.magnitude:20,Mathf.Abs(d.x)>Mathf.Abs(d.y)?48:d.magnitude));}}}
  void Update(){if(State==null)return;float scale=PixelDisplay.Scale(Screen.width,Screen.height);Viewport=new Rect(0,0,Screen.width,Screen.height);Cam.pixelRect=Viewport;Cam.orthographicSize=Screen.height/(200f*scale);
   if(Input.GetKeyDown(KeyCode.F11)){if(Screen.fullScreenMode==FullScreenMode.Windowed)Screen.SetResolution(Screen.currentResolution.width,Screen.currentResolution.height,FullScreenMode.FullScreenWindow);else Screen.SetResolution(1280,800,FullScreenMode.Windowed);}

   if(Input.GetKeyDown(KeyCode.Escape)){if(Backpack||Map){Backpack=false;Map=false;}else Menu=!Menu;}
   if(!Menu&&Input.GetKeyDown(KeyCode.Tab)){Backpack=!Backpack;Map=false;}
   if(!Menu&&Input.GetKeyDown(KeyCode.M)){Map=!Map;Backpack=false;}
   if(Input.GetKeyDown(KeyCode.F5))Save();if(Input.GetKeyDown(KeyCode.F9)){Load();Rebuild();}
   for(int n=0;n<9;n++)if(Input.GetKeyDown((KeyCode)((int)KeyCode.Alpha1+n)))Selected=n;
   if(!Menu){State.Save.phase+=Time.deltaTime/720;if(State.Save.phase>=1){State.Save.phase-=1;State.Save.day++;}saveTimer+=Time.deltaTime;if(saveTimer>30){Save();saveTimer=0;}}
   if(!Modal){MovePlayer();if(Input.GetKeyDown(KeyCode.B))Blueprint=!Blueprint;if(Input.GetKeyDown(KeyCode.R))Rotation=(Rotation+1)%4;if(Input.GetMouseButtonDown(1)){Blueprint=false;Selected=-1;}
    if(Input.GetKeyDown(KeyCode.E)){if(State.Room=="outside"&&Vector2.Distance(player,new Vector2(2120,1900))<80)Enter();else if(State.Room!="outside"&&Vector2.Distance(player,new Vector2(480,600))<75)Leave();else{Message=State.Command("interact",player,MouseWorld());Rebuild();}}
    if(Input.GetMouseButtonDown(0)&&!OverHud()){if(Blueprint){Message=State.Command("place",player,MouseWorld(),"",Rotation);Rebuild();}else if(Item!=null&&Item.StartsWith("prop:")){Message=State.Command("place_decor",player,MouseWorld(),Item,Rotation);Rebuild();}else if(swing>=.65f){strike=MouseWorld();attackDirection=(strike-player).normalized;facing=attackDirection;swing=0;impacted=false;}}
   }
   if(!Menu){Animate();if(!Modal)residents?.Tick(Time.deltaTime);}UpdateLighting();waterReflections?.Tick();CameraFollow();
  }
  bool OverHud(){var canvas=PixelDisplay.Canvas(Screen.width,Screen.height);var mouse=PixelDisplay.Pointer(Input.mousePosition,Screen.width,Screen.height);return PixelDisplay.Hud(canvas).Contains(mouse)||PixelDisplay.Hotbar(canvas).Contains(mouse);}

  Vector2 MouseWorld(){Vector3 p=Cam.ScreenToWorldPoint(Input.mousePosition);return new Vector2(p.x*100,-p.y*100);}
  void MovePlayer(){Vector2 direction=new Vector2((Input.GetKey(KeyCode.D)||Input.GetKey(KeyCode.RightArrow)?1:0)-(Input.GetKey(KeyCode.A)||Input.GetKey(KeyCode.LeftArrow)?1:0),(Input.GetKey(KeyCode.S)||Input.GetKey(KeyCode.DownArrow)?1:0)-(Input.GetKey(KeyCode.W)||Input.GetKey(KeyCode.UpArrow)?1:0));if(direction.sqrMagnitude>0)facing=direction.normalized;Vector2 step=direction.normalized*230*(Input.GetKey(KeyCode.LeftShift)?1.4f:1)*Time.deltaTime;Vector2 p=player+new Vector2(step.x,0);if(State.Walkable(player,p))player=p;p=player+new Vector2(0,step.y);if(State.Walkable(player,p))player=p;}
  void Animate(){swing+=Time.deltaTime;if(swing>=.39f&&!impacted){impacted=true;Message=State.Command("chop",player,strike);Rebuild();}int row=Mathf.Abs(facing.x)>Mathf.Abs(facing.y)?2:(facing.y<0?1:0);bool walking=Input.GetKey(KeyCode.W)||Input.GetKey(KeyCode.A)||Input.GetKey(KeyCode.S)||Input.GetKey(KeyCode.D);int frame=walking?(int)(Time.time*8)%4:0;if(swing<.65f)frame=swing<.3f?4:5;hero.Set(ReferenceArt.Frame("hero-v4",frame,row,6,4),new Vector2(48,64));hero.renderer.flipX=facing.x<0&&row==2;hero.Place(player);
   axe.renderer.enabled=swing<.85f;if(axe.renderer.enabled){int phase=swing<.13f?0:swing<.34f?1:swing<.49f?2:3;int r=Mathf.Abs(attackDirection.x)>Mathf.Abs(attackDirection.y)?(attackDirection.x<0?2:3):(attackDirection.y<0?0:1);axe.Set(ReferenceArt.Frame("axe-v4",phase,r,4,4),new Vector2(48,56));Vector2 windup=player+new Vector2(attackDirection.x<0?-30:30,-30);Vector2 point=Vector2.Lerp(windup,player+attackDirection*Mathf.Clamp(Vector2.Distance(player,strike),36,95),Mathf.SmoothStep(0,1,(swing-.23f)/.19f));axe.Place(point,Mathf.RoundToInt(player.y)+1);axe.renderer.color=new Color(.8f,1,.95f,Mathf.Clamp01(swing/.1f)*Mathf.Clamp01((.85f-swing)/.2f)*.8f);}
    foreach(var f in fires){float pulse=1+Mathf.Sin(Time.time*7+f.Key.x)*.035f;f.Value.Set(ReferenceArt.Prop("camp",4,0,(int)(Time.time*7)%4),new Vector2(56*pulse,56*pulse));f.Value.Place(new Vector2(f.Key.x,f.Key.y+8+Mathf.Sin(Time.time*7+f.Key.x)*1.5f));}
  }
  void UpdateLighting(){float phase=State.Save.phase;float daylight=Mathf.SmoothStep(0,1,Mathf.Clamp01((phase-.22f)/.12f))*Mathf.SmoothStep(0,1,Mathf.Clamp01((.84f-phase)/.14f));Color ambient=State.Room=="outside"?Color.Lerp(new Color(.28f,.32f,.49f),Color.white,daylight):new Color(.85f,.78f,.65f);Shader.SetGlobalColor("_ValleyAmbient",ambient);var lights=new List<Vector4>();foreach(var d in State.Save.decorations){if(d.location!=State.Room||lights.Count>=24)continue;if(d.family=="lamp"||d.family=="torch"||(d.family=="camp"&&d.variant==4))lights.Add(new Vector4(d.x/100,-(d.y-35)/100,1.65f,(State.Room=="outside"?1-daylight:.5f)*(.9f+Mathf.Sin(Time.time*7+d.x)*.06f)));}Shader.SetGlobalInt("_ValleyLightCount",lights.Count);if(lights.Count>0){while(lights.Count<24)lights.Add(Vector4.zero);Shader.SetGlobalVectorArray("_ValleyLights",lights.ToArray());}}
  void CameraFollow(){float halfH=Cam.orthographicSize*100,halfW=halfH*Cam.aspect;Vector2 p=State.Room=="outside"?new Vector2(halfW<2088?Mathf.Clamp(player.x,halfW,4176-halfW):2088,halfH<1560?Mathf.Clamp(player.y,halfH,3120-halfH):1560):new Vector2(480,320);Cam.transform.position=new Vector3(Mathf.Round(p.x/2)*.02f,-Mathf.Round(p.y/2)*.02f,-10);}

  public void Enter(){swing=2;impacted=true;State.Save.outside=new Position(player);State.Save.location="chief_tent";player=new Vector2(480,565);Rebuild();Message="E у выхода — вернуться";}
  public void Leave(){swing=2;impacted=true;State.Save.location="outside";player=State.Save.outside.V;Rebuild();}
  public void Save(){if(ReviewMode)return;State.Save.player=new Position(player);Directory.CreateDirectory(Path.GetDirectoryName(SavePath));string tmp=SavePath+".tmp";File.WriteAllText(tmp,JsonUtility.ToJson(State.Save,true));if(File.Exists(SavePath))File.Replace(tmp,SavePath,SavePath+".bak");else File.Move(tmp,SavePath);Message="Unity: сохранено";}
  public void Load(bool message=true){if(File.Exists(SavePath)&&State.Restore(File.ReadAllText(SavePath))){player=State.Save.player.V;if(message)Message="Unity: загружено";}}
  void OnApplicationQuit(){if(State!=null)Save();}
 }
}
