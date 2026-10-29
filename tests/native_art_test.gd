extends SceneTree
func _initialize() -> void:
 var art=preload("res://scripts/art.gd")
 var directions=preload("res://scripts/directional_art.gd")
 for family in ["bench","lamp","torch","fence","micro","camp"]:
  var count=16 if family=="micro" else (4 if family=="camp" else (2 if family in ["lamp","fence"] else 1))
  for index in range(count):
   var variant=index+4 if family=="camp" else index
   for turn in range(4):
    var texture=art.prop_texture(family,variant,0,turn)
    assert(texture!=null and texture.get_size().x>0)
    assert(texture is AtlasTexture)
 for id in range(110):
  assert(art.tree_texture(id).get_size()==Vector2(64,80))
 for row in range(4):
  for column in range(6):
   assert(directions.sheet_frame("res://assets/art/native/hero.png",column,row,6,4,Vector2i(32,32)).get_size()==Vector2(32,32))
 var file=FileAccess.open("res://assets/art/native/manifest.json",FileAccess.READ)
 var manifest=JSON.parse_string(file.get_as_text())
 assert(manifest.size()==55)
 for name in manifest:
  var source: Texture2D=load("res://assets/art/native/"+name+".png")
  assert(source.get_width()==manifest[name].size[0] and source.get_height()==manifest[name].size[1])
 print("PASS: 55 native assets, every prop and orientation, exact source cells, trees and hero dimensions")
 quit()
