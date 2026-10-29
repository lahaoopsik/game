extends RefCounted
## Native source pixels only. Textures are cropped, never reduced at runtime.
const ROOT="res://assets/art/native/"
const GRASS=preload("res://assets/art/native/ground-grass.png")
static var cache: Dictionary={}
static var occluder_cache: Dictionary={}
static func pixel_texture(texture: Texture2D, source: Rect2, _target: Vector2i) -> Texture2D:
 var key="%s:%s" % [texture.get_instance_id(),source]
 if not cache.has(key):
  var atlas=AtlasTexture.new()
  atlas.atlas=texture
  atlas.region=source
  cache[key]=atlas
 return cache[key]
static func asset(name: String) -> Texture2D:
 if not cache.has(name):
  cache[name]=load(ROOT+name+".png")
 return cache[name]
static func frame(column: int,row: int) -> Texture2D:
 return preload("res://scripts/directional_art.gd").sheet_frame(ROOT+"hero.png",column,row,6,4,Vector2i(32,32))
static func draw_native(canvas: CanvasItem, texture: Texture2D, position: Vector2,size: Vector2,tint: Color) -> void:
 var actual=texture.get_size()*2
 canvas.draw_texture_rect(texture,Rect2((position+Vector2((size.x-actual.x)/2,size.y-actual.y)).round(),actual),false,tint)
static func draw_asset(canvas: CanvasItem,column: int,_row: int,position: Vector2,size: Vector2,tint: Color=Color.WHITE) -> void:
 var texture=asset("bush") if column==2 else prop_texture("bench",0)
 draw_native(canvas,texture,position,size,tint)
static func draw_variant(canvas: CanvasItem,column: int,_row: int,position: Vector2,size: Vector2,tint: Color=Color.WHITE) -> void:
 draw_native(canvas,asset("flowers-%d" % column) if column<2 else prop_texture("micro",10),position,size,tint)
static func draw_fantasy(canvas: CanvasItem,column: int,_row: int,position: Vector2,size: Vector2,tint: Color=Color.WHITE) -> void:
 draw_native(canvas,prop_texture("micro",[10,11,13,15][column]),position,size,tint)
static func depth_texture(column: int,row: int) -> Texture2D:
 return asset("tree-%d" % column) if row==0 else prop_texture("fence" if column<2 else "lamp",column%2)
static func tree_texture(id: int) -> Texture2D:
 var layout=preload("res://scripts/valley_layout.gd")
 var variant=layout.TREE_VARIANTS[id] if id<50 else (1 if id<80 else (2 if id<96 else 3))
 return asset("tree-%d" % variant)
static func tree_occluders(id: int) -> Array:
 var texture=tree_texture(id)
 var key=texture.get_instance_id()
 if not occluder_cache.has(key):
  var bitmap=BitMap.new()
  bitmap.create_from_image_alpha(texture.get_image(),0.5)
  occluder_cache[key]=bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO,texture.get_size()),1.5)
 return occluder_cache[key]
static func prop_texture(family: String,variant: int,frame: int=0,turns: int=0) -> Texture2D:
 if family=="camp" and variant==4:
  return preload("res://scripts/directional_art.gd").sheet_frame(ROOT+"fire.png",frame%4,0,4,1,Vector2i(28,28))
 return preload("res://scripts/directional_art.gd").prop(family,variant,turns)
static func draw_oriented(canvas: CanvasItem,texture: Texture2D,_turns: int,tint: Color=Color.WHITE) -> void:
 var size=texture.get_size()*2
 canvas.draw_texture_rect(texture,Rect2(-size.x/2,-size.y+8,size.x,size.y),false,tint)
