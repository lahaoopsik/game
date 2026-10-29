using UnityEngine;
namespace SunnyValley {
 public static class PixelDisplay {
  public static float Scale(int width,int height){float fit=Mathf.Min(width/1280f,height/800f);return fit<1?Mathf.Max(.25f,fit):Mathf.Floor(fit);}
  public static Vector2 Canvas(int width,int height){float scale=Scale(width,height);return new Vector2(width/scale,height/scale);}
  public static Rect Hud(Vector2 canvas)=>new Rect(canvas.x-280,16,264,150);
  public static Rect Hotbar(Vector2 canvas)=>new Rect(canvas.x/2-296,canvas.y-94,592,80);
  public static Vector2 Pointer(Vector2 screenPointer,int width,int height)=>new Vector2(screenPointer.x,height-screenPointer.y)/Scale(width,height);
 }
}
