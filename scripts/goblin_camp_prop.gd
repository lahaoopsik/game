extends Node2D
const Art = preload("res://scripts/art.gd")

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
	texture=load("res://assets/art/native/tent-%d.png" % variant)
	native_size=texture.get_size()

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
