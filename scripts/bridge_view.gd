extends Node2D
const Art = preload("res://scripts/art.gd")
const SOURCE = preload("res://assets/art/bridge-v1.png")
func _ready() -> void:
	z_index = -2
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
func _draw() -> void:
	var texture = Art.pixel_texture(SOURCE, Rect2(Vector2.ZERO, SOURCE.get_size()), Vector2i(144, 72))
	draw_texture_rect(texture, Rect2(-144, -72, 288, 144), false)
