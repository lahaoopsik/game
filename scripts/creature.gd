extends CharacterBody2D
const Frames = preload("res://scripts/directional_art.gd")
const NAMES = ["Лесной рогозай", "Луговой слизень", "Лунный мотылёк", "Гоблин"]
var species=0
var serial=0
var home=Vector2.ZERO
var radius=120.0
var world: Node2D
var sprite: Sprite2D
var glow: PointLight2D
var age=0.0
var wait=0.0
var goal=Vector2.ZERO
var mode="idle"
var rng=RandomNumberGenerator.new()
var animation: Array[Texture2D]=[]

func _ready() -> void:
	rng.seed=731+serial*97
	collision_layer=0
	collision_mask=1
	var collider=CollisionShape2D.new()
	var shape=CircleShape2D.new()
	shape.radius=9
	collider.shape=shape
	add_child(collider)
	sprite=Sprite2D.new()
	sprite.scale=Vector2.ONE*2
	sprite.position.y=-22
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	for frame in range(4):
		animation.append(Frames.sheet_frame("res://assets/art/creatures-v1.png",frame,species,4,4,Vector2i(28,28)))
	sprite.texture=animation[0]
	if species==2:
		glow=PointLight2D.new()
		var gradient=Gradient.new()
		gradient.colors=PackedColorArray([Color(1,0.85,0.5,0.5),Color(1,0.85,0.5,0)])
		var light_texture=GradientTexture2D.new()
		light_texture.gradient=gradient
		light_texture.fill=GradientTexture2D.FILL_RADIAL
		light_texture.fill_from=Vector2(0.5,0.5)
		light_texture.fill_to=Vector2(1,0.5)
		glow.texture=light_texture
		glow.texture_scale=1.5
		glow.position.y=-26
		add_child(glow)
	choose_goal()

func active_at(phase: float) -> bool:
	return phase<0.24 or phase>0.77 if species==2 else true

func choose_goal() -> void:
	goal=home+Vector2.from_angle(rng.randf()*TAU)*rng.randf_range(15,radius)
	wait=rng.randf_range(0.6,2.8)

func _physics_process(delta: float) -> void:
	if world.indoors:
		return
	age+=delta
	var active=active_at(world.environment.phase)
	modulate.a=move_toward(modulate.a,1.0 if active else 0.0,delta*1.5)
	if is_instance_valid(glow):
		glow.energy=modulate.a*(0.65+sin(age*3)*0.1)
	if not active:
		return
	wait-=delta
	var away=position-world.player.global_position
	mode="idle"
	velocity=Vector2.ZERO
	if species==0 and away.length()<105:
		mode="flee"
		velocity=away.normalized()*90
		if position.distance_to(home)>radius:
			velocity=(home-position).normalized()*75
	elif wait<=0:
		mode="wander"
		velocity=position.direction_to(goal)*([42,24,30,32][species])
		if position.distance_to(goal)<8:
			choose_goal()
	# Gentle separation keeps groups readable without blocking the player.
	for neighbor in get_parent().get_children():
		if neighbor==self or not neighbor is CharacterBody2D:
			continue
		var offset=position-neighbor.position
		if offset.length()>0.1 and offset.length()<38:
			velocity+=offset.normalized()*(38-offset.length())*2
	var next=position+velocity*delta
	var cell=Vector2i(next/48)
	var ground=world.state.terrain
	if ground.material_at(cell)==ground.Kind.WATER or (ground.elevation_at(cell)!=ground.elevation_at(Vector2i(position/48)) and not ground.is_ramp(next)):
		velocity=Vector2.ZERO
		choose_goal()
	move_and_slide()
	if get_slide_collision_count()>0:
		choose_goal()
	if absf(velocity.x)>1:
		sprite.flip_h=velocity.x<0
	var frame=int(age*(10 if species==2 else 7))%4 if velocity.length()>1 or species==2 else 0
	sprite.texture=animation[frame]
	sprite.position.y=-22+(roundf(sin(age*5)*3) if species==2 else 0)
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO,0,Vector2(1,0.35))
	draw_circle(Vector2.ZERO,12,Color(0.1,0.16,0.12,0.13))
