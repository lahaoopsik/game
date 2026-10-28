extends CharacterBody2D
var swing: float = 0.0
var facing = Vector2.DOWN

func _ready() -> void:
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 13
	shape.shape = circle
	add_child(shape)
	z_index = 10

func _physics_process(delta: float) -> void:
	var direction = Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)), float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	velocity = direction.normalized() * 230
	if direction.length() > 0:
		facing = direction.normalized()
	move_and_slide()
	position = position.clamp(Vector2(25, 25), Vector2(2375, 1775))
	swing = maxf(0, swing - delta)
	queue_redraw()

func _draw() -> void:
	draw_ellipse_shadow()
	draw_circle(Vector2(0, -12), 15, Color("405b79"))
	draw_circle(Vector2(0, -30), 12, Color("f3d1a6"))
	draw_arc(Vector2(0, -34), 12, PI, TAU, 12, Color("613f32"), 7)
	draw_line(Vector2(-7, 0), Vector2(-7, 7), Color("473d42"), 7)
	draw_line(Vector2(7, 0), Vector2(7, 7), Color("473d42"), 7)
	var hand = Vector2(20, -17)
	if swing > 0:
		hand += facing * 13
		draw_arc(Vector2.ZERO, 45, -1.4, 1.0, 20, Color(0.7, 1, 1, 0.7), 3)
	draw_line(hand + Vector2(-5, 10), hand + Vector2(2, -14), Color("b9905b"), 4)
	draw_circle(hand + Vector2(5, -12), 8, Color("98f4ea"))

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(0, 6), 0, Vector2(1, 0.4))
	draw_circle(Vector2.ZERO, 21, Color(0.08, 0.16, 0.12, 0.25))
	draw_set_transform(Vector2.ZERO)
