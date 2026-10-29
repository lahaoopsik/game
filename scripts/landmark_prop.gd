extends Node2D
const Art = preload("res://scripts/art.gd")
var kind = "fence"
var variant = 0
var environment: Node
var sun_direction = Vector2.ZERO
var sun_length = 1.0
var sun_strength = 1.0
var light: PointLight2D
var time = 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if kind == "lamp":
		var gradient = Gradient.new()
		gradient.set_color(0, Color.WHITE)
		gradient.set_color(1, Color(1, 1, 1, 0))
		var texture = GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(0.5, 0)
		texture.width = 128
		texture.height = 128
		light = PointLight2D.new()
		light.texture = texture
		light.texture_scale = 3.2
		light.shadow_enabled = true
		light.shadow_filter = Light2D.SHADOW_FILTER_PCF5
		light.shadow_item_cull_mask = 2
		light.shadow_color = Color(0.16, 0.19, 0.23, 0.25)
		light.color = Color("ffd792") if variant == 0 else Color("a4e7ec")
		light.position = Vector2(18, -54) if variant == 0 else Vector2(0, -38)
		add_child(light)

func _process(delta: float) -> void:
	time += delta
	if is_instance_valid(light):
		var night = 1.0 - clampf((environment.tint.color.r - 0.3) / 0.65, 0, 1)
		light.energy = night * (0.9 + sin(time * 2 + position.x) * 0.04)
	queue_redraw()

func _draw() -> void:
	var texture = Art.depth_texture(variant if kind == "fence" else variant + 2, 1)
	var size = Vector2(texture.get_size()) * 2
	draw_texture_rect(texture, Rect2(Vector2(-size.x / 2, -size.y + 8), size), false)
