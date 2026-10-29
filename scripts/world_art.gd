extends Node2D
const Art = preload("res://scripts/art.gd")
var kind: String
var data: Dictionary
var time = 0.0
var observer: Node2D
var sun_direction = Vector2(-1, 1)
var sun_length = 1.0
var sun_strength = 1.0
var previous_hp = 3
var hit_time = 0.0

func _ready() -> void:
	var pixels = ShaderMaterial.new()
	pixels.shader = preload("res://assets/art/pixel.gdshader")
	pixels.set_shader_parameter("foliage", kind == "tree")
	material = pixels
	if kind == "tree":
		var texture = Art.tree_texture(int(data.id))
		for points in Art.tree_occluders(int(data.id)):
			var occluder = LightOccluder2D.new()
			var polygon = OccluderPolygon2D.new()
			polygon.polygon = points
			occluder.occluder = polygon
			occluder.position = Vector2(-64, -144)
			occluder.scale = Vector2.ONE * 2
			occluder.occluder_light_mask = 2
			add_child(occluder)

func _process(delta: float) -> void:
	time += delta
	if kind == "tree" and int(data.hp) < previous_hp:
		hit_time = 0.24
	if kind == "tree":
		previous_hp = int(data.hp)
	hit_time = maxf(0,hit_time-delta)
	material.set_shader_parameter("sun_direction", sun_direction)
	if kind == "tree" and is_instance_valid(observer):
		var hidden = observer.position.y < position.y and observer.position.distance_to(position) < 95
		modulate.a = move_toward(modulate.a, 0.28 if hidden else 1.0, delta * 4)
	queue_redraw()

func _draw() -> void:
	if kind == "tree":
		var sway = float(int(sin(time * 1.4 + float(data.id)) * 1.2)) * 2
		if hit_time > 0:
			sway += round(sin(hit_time*70) * hit_time * 24 / 2) * 2
		# Only discrete canopy translation; no fractional rotation resampling.
		var texture = Art.tree_texture(int(data.id))
		draw_texture_rect(texture, Rect2(Vector2(-64 + sway, -144), Vector2(128, 160)), false)
		if data.hp < 3:
			draw_line(Vector2(-18, 12), Vector2(-18 + int(data.hp) * 12, 12), Color("ffe1a1"), 4)
	elif kind == "bench":
		var tint = Color.WHITE if data.work >= 4 else Color(0.65, 0.95, 1, 0.45)
		var texture = preload("res://scripts/directional_art.gd").prop("bench",0,int(data.get("rotation",0)))
		if texture != null:
			Art.draw_oriented(self,texture,int(data.get("rotation",0)),tint)
		else:
			Art.draw_asset(self,3,0,Vector2(-58,-92),Vector2(116,116),tint)
		if data.work < 4:
			draw_rect(Rect2(-40, -28, 80, 56), Color("bdeee8"), false, 1)
			var progress = float(data.wood) / 12 if data.wood < 12 else float(data.work) / 4
			draw_line(Vector2(-38, 31), Vector2(-38 + 76 * progress, 31), Color("ffe2a2"), 4)
