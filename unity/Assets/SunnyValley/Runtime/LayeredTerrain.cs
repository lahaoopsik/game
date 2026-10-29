using UnityEngine;
namespace SunnyValley {
 public enum TerrainPlane { Floor, Wall, Lower }
 public static class TerrainRules {
  // Imported elevation is an authoring input. It is not player-editable height.
  // Ridge interiors become wall blocks; routes cut through them as floor.
  public static TerrainPlane Plane(Cell cell){if(cell.kind==7)return TerrainPlane.Lower;return cell.height>0&&!cell.ramp?TerrainPlane.Wall:TerrainPlane.Floor;}
  public static bool Walkable(Cell cell,bool bridge)=>cell!=null&&(Plane(cell)==TerrainPlane.Floor||(Plane(cell)==TerrainPlane.Lower&&bridge));
 }
 public class LayeredTerrain {
  readonly ValleyState state;readonly Transform parent;readonly System.Collections.Generic.List<SpriteView> views;
  public LayeredTerrain(ValleyState state,Transform parent,System.Collections.Generic.List<SpriteView> views){this.state=state;this.parent=parent;this.views=views;}
  Transform Layer(string name){var t=new GameObject(name).transform;t.SetParent(parent,false);return t;}
  SpriteView Add(Transform layer,string name,Sprite sprite,Vector2 p,Vector2 size,int order){var v=new SpriteView(layer,name,sprite,p,size,order);views.Add(v);return v;}
  public void Build(){var lower=Layer("01 Lower plane - water and void");var floor=Layer("02 Floor plane - walk and build");var wall=Layer("03 Wall plane - solid blocks");
   BlockArt.InstallMap(state.World);var water=BlockArt.Floor(7,0);var stone=BlockArt.Wall(0,0,true);var waterMaterial=new Material(Resources.Load<Shader>("Shaders/Water"));
   foreach(var cell in state.World.cells){Vector2 p=new Vector2(cell.x*48+24,cell.y*48+48);var plane=TerrainRules.Plane(cell);
    if(plane==TerrainPlane.Lower){var v=Add(lower,"Lower water "+cell.x+":"+cell.y,water,p+new Vector2(0,16),new Vector2(48,48),-12000);v.renderer.sharedMaterial=waterMaterial;}
    else {
     int variant=(cell.x*13+cell.y*7)%4;int mat=cell.kind==5?1:(cell.kind==6?2:0);Sprite top=cell.kind==4?BlockArt.Bed(cell.wet,variant):BlockArt.Floor(cell.kind,variant);
     if(plane==TerrainPlane.Wall){Add(wall,"Wall cap "+cell.x+":"+cell.y,BlockArt.Wall(mat,variant,false),p-new Vector2(0,24),new Vector2(48,48),Mathf.RoundToInt(p.y));var below=state.CellAt(new Vector2(p.x,p.y+1));if(below==null||TerrainRules.Plane(below)!=TerrainPlane.Wall){var face=Add(wall,"Wall face",BlockArt.Wall(mat,variant,true),p+new Vector2(0,8),new Vector2(48,32),Mathf.RoundToInt(p.y)+1);face.renderer.color=new Color(.66f,.63f,.53f);}}
     else Add(floor,"Floor "+cell.x+":"+cell.y,top,p,new Vector2(48,48),-10000);
     var south=state.CellAt(new Vector2(p.x,p.y+1));if(cell.kind==0&&plane==TerrainPlane.Floor&&south!=null&&south.kind!=0)Add(floor,"Grass neighbour rim",BlockArt.Rim(variant),p+new Vector2(0,12),new Vector2(48,16),-8000);if(south!=null&&TerrainRules.Plane(south)==TerrainPlane.Lower&&plane==TerrainPlane.Floor){var bank=Add(floor,"Lower shore face",stone,p+new Vector2(0,16),new Vector2(48,16),-9000);bank.renderer.color=new Color(.6f,.53f,.4f);}
    }
   }
  }
 }
}
