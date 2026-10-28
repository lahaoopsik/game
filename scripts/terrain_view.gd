extends Sprite2D
var terrain: RefCounted

func _ready() -> void:
	centered = false
	z_index = -10
	texture = preload("res://assets/art/grass-v1.png")
	scale = Vector2(2400.0 / texture.get_width(), 1800.0 / texture.get_height())
	var ground_material = ShaderMaterial.new()
	ground_material.shader = preload("res://assets/art/terrain.gdshader")
	ground_material.set_shader_parameter("ground_atlas", preload("res://assets/art/terrain-v1.png"))
	ground_material.set_shader_parameter("grass_texture", preload("res://assets/art/grass-v1.png"))
	material = ground_material
	refresh()

func refresh() -> void:
	material.set_shader_parameter("control_map", ImageTexture.create_from_image(terrain.control_image()))
