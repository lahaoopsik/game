extends Node2D
const Art = preload("res://scripts/art.gd")
var kind: String
var data: Dictionary
var time = 0.0
var observer: Node2D
var sun_direction = Vector2(-1, 1)
var sun_length = 1.0
var sun_strength = 1.0

func _ready() -> void:
	var pixels = ShaderMaterial.new()
	pixels.shader = preload("res://assets/art/pixel.gdshader")
	pixels.set_shader_parameter("foliage", kind == "tree")
	material = pixels

func _process(delta: float) -> void:
	time += delta
	material.set_shader_parameter("sun_direction", sun_direction)
	if kind == "tree" and is_instance_valid(observer):
		var hidden = observer.position.y < position.y and observer.position.distance_to(position) < 95
		modulate.a = move_toward(modulate.a, 0.5 if hidden else 1.0, delta * 4)
	queue_redraw()

func _draw() -> void:
	if kind == "tree":
		draw_set_transform(sun_direction * 19 * sun_length, sun_direction.angle(), Vector2(sun_length, 0.45))
		draw_circle(Vector2.ZERO, 33, Color(0.10, 0.17, 0.15, 0.20 * sun_strength))
		draw_set_transform(Vector2.ZERO)
		var sway = sin(time * 1.4 + float(data.id)) * 0.012
		draw_set_transform(Vector2.ZERO, sway)
		var variant = int(data.id) % 6
		var fantasy_trees = {6: 1, 12: 2, 13: 3, 14: 0, 21: 1, 32: 2, 35: 1, 46: 3}
		if fantasy_trees.has(int(data.id)):
			Art.draw_fantasy(self, fantasy_trees[int(data.id)], 0, Vector2(-75, -156), Vector2(150, 164))
		elif variant < 2:
			Art.draw_asset(self, variant, 0, Vector2(-72, -132), Vector2(144, 144))
		else:
			Art.draw_variant(self, variant - 2, 0, Vector2(-66, -134), Vector2(132, 144))
		draw_set_transform(Vector2.ZERO)
		if data.hp < 3:
			draw_line(Vector2(-18, 12), Vector2(-18 + int(data.hp) * 12, 12), Color("ffe1a1"), 4)
	elif kind == "bench":
		var tint = Color.WHITE if data.work >= 4 else Color(0.65, 0.95, 1, 0.45)
		Art.draw_asset(self, 3, 0, Vector2(-58, -92), Vector2(116, 116), tint)
		if data.work < 4:
			draw_rect(Rect2(-40, -28, 80, 56), Color("bdeee8"), false, 1)
			var progress = float(data.wood) / 12 if data.wood < 12 else float(data.work) / 4
			draw_line(Vector2(-38, 31), Vector2(-38 + 76 * progress, 31), Color("ffe2a2"), 4)
