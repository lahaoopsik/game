using System;
using System.IO;
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
namespace SunnyValley.Editor {
 public class ReferenceTextureImporter:AssetPostprocessor {
  void OnPreprocessTexture(){if(!assetPath.Contains("Resources/Art/")&&!assetPath.Contains("Resources/Blocks/"))return;var t=(TextureImporter)assetImporter;t.textureType=TextureImporterType.Default;t.filterMode=FilterMode.Point;t.mipmapEnabled=false;t.npotScale=TextureImporterNPOTScale.None;t.textureCompression=TextureImporterCompression.Uncompressed;t.maxTextureSize=8192;t.alphaIsTransparency=true;}
 }
 public static class ProjectSetup {
  static void Check(bool value,string message){if(!value)throw new Exception("FAILED: "+message);}
  [MenuItem("Sunny Valley/Verify migration")]
  public static void Verify(){
   AssetDatabase.ImportAsset("Assets/Resources/Blocks",ImportAssetOptions.ForceUpdate|ImportAssetOptions.ImportRecursive);
   var data=JsonUtility.FromJson<WorldData>(Resources.Load<TextAsset>("Data/world").text);Check(data.cells.Length==87*65,"authored terrain");Check(TerrainRules.Plane(new Cell{kind=7})==TerrainPlane.Lower,"lower water plane");Check(!TerrainRules.Walkable(new Cell{kind=7},false)&&TerrainRules.Walkable(new Cell{kind=7},true),"water blocked except bridge");Check(!TerrainRules.Walkable(new Cell{height=1},false)&&TerrainRules.Walkable(new Cell{height=1,ramp=true},false),"solid wall and floor passage");var stats=new System.Text.StringBuilder("seed,basins,trees,grass,water_cells\n");for(int seed=0;seed<100;seed++){var generated=StarterGenerator.Generate(seed,data);Check(StarterGenerator.Validate(generated,out _),"generator seed "+seed);int waterCount=0;foreach(var cell in generated.cells)if(cell.kind==7)waterCount++;stats.AppendLine(seed+","+generated.basinCount+","+generated.trees.Length+","+generated.grass.Length+","+waterCount);if(seed==7)Check(JsonUtility.ToJson(generated)==JsonUtility.ToJson(StarterGenerator.Generate(seed,data)),"seed deterministic");}Directory.CreateDirectory("Reports");File.WriteAllText("Reports/generation.csv",stats.ToString());Debug.Log("PASS GENERATION: 100 seeds, walk connectivity, 3-5 basins, water budget, starter trees and repeatable seed");var state=new ValleyState(data);var inv=state.Save.inventory;for(int i=0;i<9;i++)Check(inv.Add("item"+i,1),"fill hotbar");Check(inv.Add("wood",5)&&inv.pocket[0].item=="wood","reserve overflow");Check(inv.Move(true,0,false,0)&&inv.hotbar[0].item=="wood"&&inv.pocket[0].item=="item0","drag swap");Check(inv.Remove("wood",3)&&inv.Count("wood")==2,"resource removal");
   state=new ValleyState(data);foreach(var c in data.cells){if(c.kind!=7)continue;Vector2 waterPoint=new Vector2(c.x*48+24,c.y*48+24);if(!state.Bridge(waterPoint)){Check(!state.Walkable(waterPoint,waterPoint),"actual lower water collision");break;}}var t=state.Save.trees[0];Vector2 p=new Vector2(t.x,t.y);int hp=t.hp;state.Command("chop",p+Vector2.one*400,p);Check(t.hp==hp,"reach validation");state.Command("chop",p,p);state.Command("chop",p,p);state.Command("chop",p,p);Check(state.Save.inventory.Count("wood")==5,"chop reward once");string json=JsonUtility.ToJson(state.Save);var restored=new ValleyState(data);Check(restored.Restore(json)&&restored.Save.inventory.Count("wood")==5,"save round trip");Check(!restored.Restore("{}"),"invalid save rejected");
   foreach(string name in new[]{"hero-v3","depth-scenery-v3","bridge-v1","rotation-a-v1","goblin-camp-v3"})Check(Resources.Load<Texture2D>("Art/"+name)!=null,"reference art "+name);
   Debug.Log("PASS UNITY MIGRATION: map, inventory overflow and drag, command reach, tree rewards, save roundtrip and art imports");
  }
  [MenuItem("Sunny Valley/Prepare scene")]
  public static void Prepare(){Directory.CreateDirectory("Assets/Scenes");var scene=EditorSceneManager.NewScene(NewSceneSetup.EmptyScene,NewSceneMode.Single);new GameObject("Sunny Valley").AddComponent<ValleyGame>();var camera=new GameObject("Main Camera").AddComponent<Camera>();camera.tag="MainCamera";camera.orthographic=true;camera.orthographicSize=4;camera.transform.position=new Vector3(12,-9,-10);EditorSceneManager.SaveScene(scene,"Assets/Scenes/Valley.unity");EditorBuildSettings.scenes=new[]{new EditorBuildSettingsScene("Assets/Scenes/Valley.unity",true)};PlayerSettings.companyName="SunnyValley";PlayerSettings.productName="Солнечная долина — Unity";PlayerSettings.defaultScreenWidth=1280;PlayerSettings.defaultScreenHeight=800;PlayerSettings.fullScreenMode=FullScreenMode.Windowed;PlayerSettings.runInBackground=true;AssetDatabase.SaveAssets();}
  public static void VerifyAndPrepare(){Verify();Prepare();}
  public static void Build(){VerifyAndPrepare();Directory.CreateDirectory("Builds/Windows");var report=BuildPipeline.BuildPlayer(EditorBuildSettings.scenes,"Builds/Windows/SunnyValley.exe",BuildTarget.StandaloneWindows64,BuildOptions.None);if(report.summary.result!=UnityEditor.Build.Reporting.BuildResult.Succeeded)throw new Exception("Unity build failed");}
 }
}
