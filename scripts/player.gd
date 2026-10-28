extends CharacterBody2D
const Art = preload("res://scripts/art.gd")
var swing: float = 0.0
var facing = Vector2.DOWN
var animation_time = 0.0
var sprite: Sprite2D
var weapon: Node2D
const WALK_SPEED = 230.0
const RUN_MULTIPLIER = 1.4
var input_locked = false

func _ready() -> void:
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 13
	shape.shape = circle
	add_child(shape)
	sprite = Sprite2D.new()
	var pixels = ShaderMaterial.new()
	pixels.shader = preload("res://assets/art/pixel.gdshader")
	sprite.material = pixels
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * 0.30
	sprite.position = Vector2(0, -37)
	add_child(sprite)
	weapon = preload("res://scripts/weapon.gd").new()
	add_child(weapon)
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
	var light = PointLight2D.new()
	light.texture = glow_image
	light.texture_scale = 2.4
	light.color = Color("a9eee3")
	light.energy = 0.65
	light.position = Vector2(18, -20)
	add_child(light)

func _physics_process(delta: float) -> void:
	var direction = Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)), float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	var running = Input.is_physical_key_pressed(KEY_SHIFT)
	if input_locked:
		direction = Vector2.ZERO
	velocity = direction.normalized() * WALK_SPEED * (RUN_MULTIPLIER if running else 1.0)
	if direction.length() > 0:
		facing = direction.normalized()
	move_and_slide()
	position = position.clamp(Vector2(25, 25), Vector2(2375, 1775))
	swing = maxf(0, swing - delta)
	animation_time += delta * (RUN_MULTIPLIER if running else 1.0)
	var row = 1
	if absf(facing.x) > absf(facing.y):
		row = 3
	elif facing.y < 0:
		row = 2
	var column = int(animation_time * 8.0) % 4 if velocity.length() > 1 else 0
	sprite.texture = Art.frame(column, row)
	sprite.flip_h = row == 3 and facing.x < 0
	sprite.position.y = -37 + (sin(animation_time * 2.5) * 0.7 if velocity.length() < 1 else 0.0)
	if weapon.progress >= 1.0:
		weapon.direction = facing
	sprite.rotation = sin(weapon.progress * PI) * 0.10 if weapon.progress < 1.0 else 0.0
	queue_redraw()

func _draw() -> void:
	draw_ellipse_shadow()

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(0, 6), 0, Vector2(1, 0.4))
	draw_circle(Vector2.ZERO, 21, Color(0.08, 0.16, 0.12, 0.25))
	draw_set_transform(Vector2.ZERO)
