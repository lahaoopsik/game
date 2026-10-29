using System.Collections;
using System.IO;
using UnityEngine;
namespace SunnyValley {
 public class MigrationReview:MonoBehaviour {
  [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]static void Boot(){var args=System.Environment.GetCommandLineArgs();for(int i=0;i<args.Length-1;i++)if(args[i]=="-valleyCapture"){var r=new GameObject("Capture review").AddComponent<MigrationReview>();r.path=args[i+1];}}
  string path;
  IEnumerator Shot(string destination){yield return new WaitForEndOfFrame();var texture=ScreenCapture.CaptureScreenshotAsTexture();if(!texture)throw new System.Exception("Capture produced no texture");File.WriteAllBytes(destination,texture.EncodeToPNG());Destroy(texture);if(!File.Exists(destination))throw new System.Exception("Capture not saved");}
  IEnumerator Start(){yield return new WaitForSeconds(2);var game=FindFirstObjectByType<ValleyGame>();if(!game)throw new System.Exception("Review game missing");Vector2 original=game.player;float frame=Time.frameCount;
   int lx=(int)(game.State.World.lake.x/48),ly=(int)(game.State.World.lake.y/48);while(ly>1&&game.State.World.cells[(ly-1)*87+lx].kind==7)ly--;game.player=new Vector2(lx*48+24,(ly-1)*48+24);game.State.Save.phase=.42f;yield return new WaitForSeconds(1);yield return Shot(path);
   game.State.Save.phase=.92f;yield return new WaitForSeconds(1);yield return Shot(Path.ChangeExtension(path,"night.png"));
   game.player=new Vector2(2120,2140);game.State.Save.phase=.42f;yield return new WaitForSeconds(1);yield return Shot(Path.ChangeExtension(path,"village.png"));
   game.Map=true;yield return new WaitForSeconds(.2f);yield return Shot(Path.ChangeExtension(path,"map.png"));game.Map=false;
   game.Enter();yield return new WaitForSeconds(.2f);yield return Shot(Path.ChangeExtension(path,"interior.png"));game.Leave();
   if(Time.frameCount<=frame+3)throw new System.Exception("Runtime not advancing");Debug.Log("PASS UNITY RUNTIME: live frames, water/day/night/village/map/interior screenshots saved, seed "+game.State.World.seed+", basins "+game.State.World.basinCount);game.player=original;Destroy(game);Application.Quit();
  }
 }
}
