extends Node2D
const Art = preload("res://scripts/art.gd")
var data: Dictionary
var environment: Node
var sun_direction = Vector2.ZERO
var sun_length = 1.0
var sun_strength = 1.0
var time = 0.0
var light: PointLight2D
var state: RefCounted
var connections: Dictionary = {}
var rail_texture: Texture2D
var post_texture: Texture2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if data.family=="fence" or (data.family=="camp" and data.variant==6):
		connections = preload("res://scripts/fence_graph.gd").connections(state.decorations,data)
		var front = Art.prop_texture(data.family,int(data.variant),0,0)
		rail_texture = Art.pixel_texture(front,Rect2(12,8,24,16),Vector2i(24,16))
		var end = Art.prop_texture(data.family,int(data.variant),0,1)
		var used = end.get_image().get_used_rect()
		post_texture = Art.pixel_texture(end,Rect2(used),Vector2i(12,28))
	if data.family in ["lamp", "torch"] or (data.family == "camp" and data.variant == 4):
		var gradient = Gradient.new()
		gradient.set_color(0, Color.WHITE)
		gradient.set_color(1, Color(1,1,1,0))
		var texture = GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5,0.5)
		texture.fill_to = Vector2(0.5,0)
		texture.width = 128
		texture.height = 128
		light = PointLight2D.new()
		light.texture = texture
		light.texture_scale = 2.8
		light.color = Color("a6e0e5") if data.family == "lamp" and data.variant == 1 else Color("ffd296")
		light.position = Vector2(0,-58) if data.family in ["lamp","torch"] else Vector2(0,-16)
		light.shadow_enabled = true
		light.shadow_item_cull_mask = 2
		light.shadow_filter = Light2D.SHADOW_FILTER_PCF5
		light.shadow_color = Color(0.16,0.19,0.22,0.24)
		add_child(light)

func _process(delta: float) -> void:
	time += delta
	if is_instance_valid(light):
		var night = 1 - clampf((environment.tint.color.r - 0.3) / 0.65, 0, 1)
		light.energy = (0.12 + 0.75 * night) * (0.96 + sin(time * 7 + position.x) * 0.04)
	queue_redraw()

func _draw() -> void:
	if (data.family=="fence" or (data.family=="camp" and data.variant==6)) and not connections.is_empty():
		for offset in connections.values():
			var half: Vector2 = offset/2
			if absf(half.x)>absf(half.y):
				var a = Vector2.ZERO if half.x>0 else half
				var b = half if half.x>0 else Vector2.ZERO
				draw_polygon(PackedVector2Array([a+Vector2(0,-42),b+Vector2(0,-42),b+Vector2(0,-10),a+Vector2(0,-10)]),PackedColorArray([Color.WHITE]),PackedVector2Array([Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,1)]),rail_texture)
			else:
				draw_texture_rect(rail_texture,Rect2(-6,minf(0,half.y)-30,12,absf(half.y)+22),false)
		draw_texture_rect(post_texture,Rect2(-12,-48,24,56),false)
		return
	var frame = int(time * 7) % 3 if data.family == "torch" else 0
	if data.family == "camp" and data.variant == 4:
		frame = int(time*7)%4
	var turns = int(data.get("rotation",0))
	var variant = int(data.variant)
	var texture = Art.prop_texture(data.family, variant, frame, turns)
	if data.family == "micro" and variant in [6,7,12,15]:
		draw_set_transform(Vector2(2 if sin(time * 1.4 + position.x) > 0.6 else 0,0))
	Art.draw_oriented(self, texture, turns if data.family != "fence" else (2 if turns >= 2 else 0))
	if data.family == "camp" and variant == 4:
		for i in range(3):
			var p = Vector2(sin(time + i * 2) * 9,-fmod(time * 12 + i * 11,42)-12)
			draw_rect(Rect2(p,Vector2(2,2)),Color(1,0.77,0.36,0.55))
		for i in range(3):
			var age = fmod(time*0.3+i*0.33,1.0)
			var p = Vector2(sin(time*0.6+i)*7,-35-age*36)
			draw_rect(Rect2((p/2).round()*2,Vector2(4,4)),Color(0.73,0.72,0.66,(1-age)*0.15))
