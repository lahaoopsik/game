extends Node2D
const Layout = preload("res://scripts/valley_layout.gd")
var time = 0.0
var environment: Node

func _ready() -> void:
	var shader = Shader.new()
	shader.code = "shader_type canvas_item; render_mode unshaded;"
	var unshaded = ShaderMaterial.new()
	unshaded.shader = shader
	material = unshaded

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	var daylight = clampf((environment.tint.color.r - 0.3) / 0.5, 0, 1)
	for zone_index in range(Layout.FLOWER_BEDS.size()):
		var center: Vector2 = Layout.FLOWER_BEDS[zone_index]
		for i in range(2):
			var phase = time * 0.4 + zone_index * 1.8 + i * 2.3
			var p = center + Vector2(sin(phase) * 65, cos(phase * 1.7) * 30 - 18)
			var wing = 2 + absf(sin(time * 11 + zone_index)) * 4
			var color = Color("e5b1b0") if zone_index % 2 == 0 else Color("eee3a0")
			color.a = daylight
			draw_rect(Rect2(p - Vector2(wing, 2), Vector2(wing - 1, 4)), color)
			draw_rect(Rect2(p + Vector2(1, -2), Vector2(wing - 1, 4)), color)
			draw_line(p + Vector2(0, -2), p + Vector2(0, 3), Color(0.25, 0.3, 0.2, daylight), 1)
	var night = 1 - daylight
	for center in [Vector2(825, 740), Vector2(1420, 630), Vector2(1590, 1130), Vector2(1710, 1380)]:
		for i in range(3):
			var p: Vector2 = center + Vector2(sin(time * 0.6 + i * 2.1) * 18, -fmod(time * 6 + i * 12, 40))
			draw_rect(Rect2(p, Vector2(2, 2)), Color(0.75, 1, 0.85, night * (0.4 + 0.2 * sin(time * 2 + i))))
	for zone_index in range(Layout.FIREFLY_ZONES.size()):
		for i in range(5):
			var phase = time * 0.25 + i * 1.8 + zone_index
			var p: Vector2 = Layout.FIREFLY_ZONES[zone_index] + Vector2(sin(phase) * 85, cos(phase * 1.4) * 45)
			var alpha = night * (0.25 + 0.75 * pow(absf(sin(time * 1.3 + i * 2.1)), 3))
			draw_circle(p, 7, Color(0.75, 1, 0.45, alpha * 0.08))
			draw_circle(p, 4, Color(0.85, 1, 0.6, alpha * 0.14))
			draw_rect(Rect2(p - Vector2.ONE, Vector2.ONE * 2), Color(0.94, 1, 0.65, alpha))
