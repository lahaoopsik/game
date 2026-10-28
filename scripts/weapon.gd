extends Node2D
const TEXTURE = preload("res://assets/art/spectral-axe-v2.png")
var progress = 1.0
var direction = Vector2.DOWN
var ambient = 1.0
var light: PointLight2D
var chips: Array = []
var summon_age = 100.0
var hover_time = 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var pixels = ShaderMaterial.new()
	pixels.shader = preload("res://assets/art/pixel.gdshader")
	material = pixels
	var glow_image = GradientTexture2D.new()
	var gradient = Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color(1, 1, 1, 0))
	glow_image.gradient = gradient
	glow_image.fill = GradientTexture2D.FILL_RADIAL
	glow_image.fill_from = Vector2(0.5, 0.5)
	glow_image.fill_to = Vector2(0.5, 0.0)
	glow_image.width = 128
	glow_image.height = 128
	light = PointLight2D.new()
	light.texture = glow_image
	light.texture_scale = 2.6
	light.color = Color("8fddd3")
	light.position = Vector2(20, -25)
	add_child(light)

func attack(facing: Vector2, hit: bool) -> void:
	direction = facing
	progress = 0.0
	summon_age = 0.0
	if hit:
		for i in range(8):
			var angle = float(i) / 8 * TAU
			chips.append({"p": direction * 38 + Vector2(0, -12), "v": Vector2(cos(angle) * 50, sin(angle) * 40 - 45), "life": 0.4})

func _process(delta: float) -> void:
	summon_age += delta
	hover_time += delta
	progress = minf(1.0, progress + delta / 0.25)
	for chip in chips:
		chip.life -= delta
		chip.p += chip.v * delta
		chip.v.y += 180 * delta
	chips = chips.filter(func(chip): return chip.life > 0)
	light.energy = maxf(0, 1 - summon_age / 1.4) * (0.2 + (1 - ambient) * 0.6)
	queue_redraw()

func _draw() -> void:
	var active = progress < 1.0
	var side = -1.0 if direction.x < 0 else 1.0
	var visibility = clampf(1.0 - maxf(0, summon_age - 0.45), 0.0, 1.0)
	var hand = Vector2(side * 35, -31 + sin(hover_time * 4) * 3)
	var angle = side * 0.15
	if active:
		var aim = direction.angle() + PI / 2
		angle = aim + lerpf(-1.25, 1.2, smoothstep(0.2, 0.85, progress))
		hand = direction * (24 + sin(progress * PI) * 12) + Vector2(0, -25)
		var alpha = sin(progress * PI) * 0.75
		draw_arc(Vector2(0, -14), 43, direction.angle() - 0.9, direction.angle() + 0.9, 12, Color(0.65, 1, 0.94, alpha), 5)
	draw_set_transform(hand, angle)
	# Atlas-independent pivot at lower handle, alpha margins retained in original.
	draw_texture_rect(TEXTURE, Rect2(-14, -43, 39, 52), false, Color(0.8, 1.0, 0.97, visibility * 0.64))
	draw_set_transform(Vector2.ZERO)
	for i in range(5):
		var orbit = hover_time * 2 + i * TAU / 5
		var mote = hand + Vector2(cos(orbit) * 20, sin(orbit) * 12)
		draw_rect(Rect2(mote, Vector2(2, 2)), Color(0.65, 1, 0.92, visibility * 0.7))
	for chip in chips:
		draw_rect(Rect2(chip.p, Vector2(4, 2)), Color(0.87, 0.68, 0.36, chip.life / 0.4))
