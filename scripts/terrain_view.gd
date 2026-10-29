extends Sprite2D
var terrain: RefCounted

func _ready() -> void:
	centered = false
	z_index = -10
	texture = preload("res://assets/art/grass-v1.png")
	scale = preload("res://scripts/valley_layout.gd").WORLD_SIZE / Vector2(texture.get_size())
	var ground_material = ShaderMaterial.new()
	ground_material.shader = preload("res://assets/art/terrain.gdshader")
	ground_material.set_shader_parameter("ground_atlas", preload("res://assets/art/terrain-v3.png"))
	ground_material.set_shader_parameter("grass_texture", preload("res://assets/art/grass-v1.png"))
	material = ground_material
	ground_material.set_shader_parameter("world_size", preload("res://scripts/valley_layout.gd").WORLD_SIZE)
	ground_material.set_shader_parameter("grid_size", Vector2(terrain.SIZE))
	refresh()

func refresh() -> void:
	material.set_shader_parameter("control_map", ImageTexture.create_from_image(terrain.control_image()))
