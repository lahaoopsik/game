extends RefCounted
## Exact native cells; no image resize, alpha recropping or auto scaling.
static var cache: Dictionary={}
const ROOT="res://assets/art/native/"
static func direction_index(direction: Vector2) -> int:
 if absf(direction.x)>absf(direction.y):return 2 if direction.x<0 else 3
 return 1 if direction.y<0 else 0
static func sheet_frame(path: String,column: int,row: int,columns: int,rows: int,_native: Vector2i) -> Texture2D:
 var names={"hero-v3.png":"hero.png","axe-directional-v3.png":"axe.png","creatures-v1.png":"creatures.png","campfire-v2.png":"fire.png"}
 if names.has(path.get_file()):path=ROOT+names[path.get_file()]
 var key="%s:%d:%d" % [path,column,row]
 if not cache.has(key):
  var source: Texture2D=load(path)
  var cell=source.get_size()/Vector2(columns,rows)
  var atlas=AtlasTexture.new()
  atlas.atlas=source
  atlas.region=Rect2(Vector2(column,row)*cell,cell)
  cache[key]=atlas
 return cache[key]
static func prop(family: String,variant: int,turns: int) -> Texture2D:
 var path=ROOT+"%s-%d.png" % [family,variant]
 if not ResourceLoader.exists(path):return null
 return sheet_frame(path,(turns+variant)%4 if family=="fence" else turns%4,0,4,1,Vector2i.ZERO)
