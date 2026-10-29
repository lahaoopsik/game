extends Node2D
const Art = preload("res://scripts/art.gd")
const SOURCE = preload("res://assets/art/native/grass.png")
var state: RefCounted
var time = 0.0
var textures: Array = []

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for i in range(4):
		textures.append(Art.pixel_texture(SOURCE,Rect2(i*16,0,16,24),Vector2i(16,24)))

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	for clump in state.grass:
		var screen=get_viewport_transform()*Vector2(clump.x,clump.y)
		if not Rect2(Vector2(-60,-60),get_viewport_rect().size+Vector2(120,120)).has_point(screen):
			continue
		var sway = 2 if sin(time * 1.5 + clump.x * 0.03) > 0.5 else 0
		var size=Vector2(32,48)
		var p = Vector2(clump.x - size.x/2 + sway, clump.y - size.y+4)
		draw_texture_rect(textures[clump.variant], Rect2(p, size), false)
