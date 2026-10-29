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
var movement_bounds = Rect2(Vector2.ZERO,preload("res://scripts/valley_layout.gd").WORLD_SIZE)
var indoors = false

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
	sprite.scale = Vector2.ONE * 2.0
	sprite.position = Vector2(0, -36)
	add_child(sprite)
	weapon = preload("res://scripts/weapon.gd").new()
	add_child(weapon)
func _physics_process(delta: float) -> void:
	var direction = Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)), float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	var running = Input.is_physical_key_pressed(KEY_SHIFT)
	if input_locked:
		direction = Vector2.ZERO
	velocity = direction.normalized() * WALK_SPEED * (RUN_MULTIPLIER if running else 1.0)
	if direction.length() > 0:
		facing = direction.normalized()
	move_and_slide()
	position = position.clamp(movement_bounds.position+Vector2(25,25),movement_bounds.end-Vector2(25,25))
	if indoors:
		var relative=(position-Vector2(480,330))/Vector2(410,250)
		if relative.length()>1 and not (absf(position.x-480)<55 and position.y>520):
			position=Vector2(480,330)+relative.normalized()*Vector2(410,250)
	swing = maxf(0, swing - delta)
	animation_time += delta * (RUN_MULTIPLIER if running else 1.0)
	var row = 0
	if absf(facing.x) > absf(facing.y): row=2
	elif facing.y<0: row=1
	var column = int(animation_time * 8.0) % 4 if velocity.length() > 1 else 0
	if weapon.progress < 1:
		column = 4 if weapon.progress<0.45 else 5
		if absf(weapon.direction.x)>absf(weapon.direction.y): row=3 if weapon.direction.x<0 else 2
		else: row=1 if weapon.direction.y<0 else 0
	var texture = preload("res://scripts/directional_art.gd").sheet_frame("res://assets/art/hero-v3.png",column,row,6,4,Vector2i(32,32))
	sprite.texture = texture if texture!=null else Art.frame(column%4,1)
	sprite.flip_h = column<4 and facing.x<0 and absf(facing.x)>absf(facing.y)
	sprite.position.y = -32
	if weapon.progress >= 1.0:
		weapon.direction = facing
	sprite.rotation = 0.0
	queue_redraw()

func _draw() -> void:
	draw_ellipse_shadow()

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(0, 6), 0, Vector2(1, 0.4))
	draw_circle(Vector2.ZERO, 18, Color(0.08, 0.16, 0.12, 0.14))
	draw_set_transform(Vector2.ZERO)
