extends Node2D
const Art = preload("res://scripts/art.gd")
const SOURCE = preload("res://assets/art/goblin-camp-v3.png")
var variant = 0
var environment: Node
var sun_direction = Vector2.ZERO
var sun_length = 1.0
var sun_strength = 1.0
var time = 0.0
var texture: Texture2D
var native_size: Vector2i

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var dimensions = Vector2(SOURCE.get_size())
	var column = variant if variant < 4 else variant - 4
	var left = [0.0, 0.315, 0.513, 0.747][column] if variant < 4 else column / 4.0
	var right = [0.315, 0.513, 0.747, 1.0][column] if variant < 4 else (column + 1) / 4.0
	var top = 0.05 if variant < 4 else 0.64
	var bottom = 0.61 if variant < 4 else 0.98
	native_size = [Vector2i(96, 80), Vector2i(56, 52), Vector2i(56, 52), Vector2i(56, 48), Vector2i(36, 24), Vector2i(36, 32), Vector2i(48, 30), Vector2i(28, 36)][variant]
	var source = Rect2(Vector2(left * dimensions.x, top * dimensions.y), Vector2((right - left) * dimensions.x, (bottom - top) * dimensions.y))
	texture = Art.pixel_texture(SOURCE, source, native_size)

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	if texture == null:
		return
	var size = Vector2(native_size) * 2
	draw_texture_rect(texture, Rect2(Vector2(-size.x / 2, -size.y + 10), size), false)
	if variant == 4:
		# The campfire is scenery; its flicker does not imply cooking mechanics.
		var height = 10 + int(sin(time * 8) * 2) * 2
		draw_rect(Rect2(-5, -18 - height, 10, height), Color("e9a14e"))
		draw_rect(Rect2(-2, -18 - height / 2, 4, height / 2), Color("ffe299"))
