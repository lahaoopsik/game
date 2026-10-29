extends Node2D
var texture: Texture2D
var tree = false
var age = 0.0
var time_to_live = 0.28
var sign_x = 1.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if tree:
		time_to_live = 0.65

func _process(delta: float) -> void:
	age += delta
	if age >= time_to_live:
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	if texture == null:
		return
	var progress = age / time_to_live
	var shake = round(sin(age * 65) * (1-progress) * 3) * 2
	var tint = Color(1,1,1,1-smoothstep(0.35,1.0,progress))
	if tree:
		var angle = sign_x * pow(progress,2) * 0.9
		draw_set_transform(Vector2(shake,0),angle)
	var size = Vector2(texture.get_size()) * 2
	draw_texture_rect(texture,Rect2(Vector2(-size.x/2+shake,-size.y+8),size),false,tint)
	draw_set_transform(Vector2.ZERO)
