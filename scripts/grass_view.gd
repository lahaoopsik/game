extends Node2D
const Art = preload("res://scripts/art.gd")
const SOURCE = preload("res://assets/art/grass-clumps-v1.png")
var state: RefCounted
var time = 0.0
var textures: Array = []

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for i in range(4):
		var source = Rect2(i * SOURCE.get_width() / 4.0, SOURCE.get_height() * 0.04, SOURCE.get_width() / 4.0, SOURCE.get_height() * 0.54)
		textures.append(Art.pixel_texture(SOURCE, source, Vector2i(16, 24)))

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	for clump in state.grass:
		var sway = 2 if sin(time * 1.5 + clump.x * 0.03) > 0.5 else 0
		var p = Vector2(clump.x - 16 + sway, clump.y - 44)
		draw_texture_rect(textures[clump.variant], Rect2(p, Vector2(32, 48)), false)
