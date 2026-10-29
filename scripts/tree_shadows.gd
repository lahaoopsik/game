extends Node2D
const Art = preload("res://scripts/art.gd")
var state: RefCounted
var sun_direction = Vector2(0.5, 0.6)
var sun_length = 1.0
var sun_strength = 1.0

func _ready() -> void:
	z_index = -1
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var shadow_material = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = "shader_type canvas_item; varying vec4 tint; void vertex(){tint=COLOR;} void fragment(){vec2 s=TEXTURE_PIXEL_SIZE; float a=texture(TEXTURE,UV).a*0.4; a+=(texture(TEXTURE,UV+vec2(s.x,0)).a+texture(TEXTURE,UV-vec2(s.x,0)).a+texture(TEXTURE,UV+vec2(0,s.y)).a+texture(TEXTURE,UV-vec2(0,s.y)).a)*0.15; COLOR=vec4(0.16,0.23,0.20,a*tint.a);}"
	shadow_material.shader = shader
	material = shadow_material

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	for tree in state.trees:
		var texture = Art.tree_texture(int(tree.id))
		var basis = Transform2D(Vector2(0.9, 0.03), Vector2(-sun_direction.x * 0.65 * sun_length, -sun_direction.y * 0.36 * sun_length), Vector2(tree.x, tree.y))
		draw_set_transform_matrix(basis)
		draw_texture_rect(texture, Rect2(-64, -144, 128, 160), false, Color(1, 1, 1, 0.13 * sun_strength))
		draw_set_transform_matrix(Transform2D.IDENTITY)
