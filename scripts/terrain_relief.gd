extends Node2D
const Art=preload("res://scripts/art.gd")
var terrain: RefCounted
var edges: Array=[]
var sides: Array=[]
var tiles: Array=[]
var time=0.0

func _ready() -> void:
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 z_index=-2
 var source: Texture2D=load("res://assets/art/native/cliffs.png")
 for i in range(8):
  tiles.append(Art.pixel_texture(source,Rect2(Vector2(i%4,i/4)*source.get_size()/Vector2(4,2),source.get_size()/Vector2(4,2)),Vector2i(24,24)))
 for y in range(terrain.SIZE.y-1):
  for x in range(terrain.SIZE.x-1):
   var current=terrain.elevation_at(Vector2i(x,y))
   var lower=terrain.elevation_at(Vector2i(x,y+1))
   if current>lower:
    edges.append({"x":x*48,"y":(y+1)*48,"height":mini(96,(current-lower)*32),"ramp":terrain.is_ramp(Vector2(x*48+24,(y+1)*48)),"water":terrain.material_at(Vector2i(x,y))==7})
   var right=terrain.elevation_at(Vector2i(x+1,y))
   if current!=right and not terrain.is_ramp(Vector2((x+1)*48,y*48+24)):
    sides.append({"p":Vector2((x+1)*48,y*48),"left":current<right})

func _process(delta: float) -> void:
 time+=delta
 queue_redraw()

func _draw() -> void:
 if tiles.is_empty():
  return
 for side in sides:
  var p: Vector2=side.p
  draw_set_transform(p if side.left else p+Vector2(0,48),PI/2 if side.left else -PI/2)
  draw_texture_rect(tiles[0],Rect2(Vector2.ZERO,Vector2(48,24)),false)
  draw_set_transform(Vector2.ZERO)
 for edge in edges:
  var p=Vector2(edge.x,edge.y)
  if edge.water:
   draw_rect(Rect2(p,Vector2(48,edge.height+8)),Color("80cfdc"))
   for i in range(6):
    var start=int(time*10+i*3)%8
    draw_line(p+Vector2(i*8,start),p+Vector2(i*8,edge.height),Color("d4f1e2"),2)
   draw_line(p+Vector2(0,edge.height+8),p+Vector2(48,edge.height+8),Color("e5f3dd"),4)
  elif edge.ramp:
   draw_texture_rect(tiles[6],Rect2(p-Vector2(0,8),Vector2(48,40)),false)
  else:
   # Painted rock face and grass lip, plus a restrained contact shadow.
   draw_rect(Rect2(p+Vector2(0,edge.height),Vector2(48,6)),Color(0.16,0.2,0.12,0.12))
   draw_texture_rect(tiles[(int(edge.x)/48+int(edge.y)/48)%4],Rect2(p-Vector2(0,4),Vector2(48,edge.height+4)),false)
