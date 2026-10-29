extends Node2D
signal impact
const DURATION = 0.65
const Directional = preload("res://scripts/directional_art.gd")
var progress = 1.0
var direction = Vector2.DOWN
var ambient = 1.0
var light: PointLight2D
var chips: Array = []
var summon_age = 100.0
var hover_time = 0.0
var target_distance = 65.0
var impact_emitted = true

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var gradient = Gradient.new()
	gradient.set_color(0,Color.WHITE)
	gradient.set_color(1,Color(1,1,1,0))
	var texture = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5,0.5)
	texture.fill_to = Vector2(0.5,0)
	texture.width = 128
	texture.height = 128
	light = PointLight2D.new()
	light.texture = texture
	light.texture_scale = 1.7
	light.color = Color("9be5dd")
	add_child(light)

func attack(facing: Vector2, _hit: bool = false, distance: float = 65.0) -> void:
	direction = facing.normalized()
	progress = 0
	summon_age = 0
	impact_emitted = false
	target_distance = clampf(distance,36,95)

func register_hit(kind: String) -> void:
	for i in range(10):
		var angle = i * TAU / 10
		chips.append({"p":direction*target_distance+Vector2(0,-8),"v":Vector2(cos(angle)*55,sin(angle)*30-55),"life":0.4,"leaf":kind=="grass" or i%3==0})

func _process(delta: float) -> void:
	summon_age += delta
	hover_time += delta
	progress = minf(1,progress+delta/DURATION)
	if not impact_emitted and progress >= 0.6:
		impact_emitted = true
		impact.emit()
	for chip in chips:
		chip.life -= delta
		chip.p += chip.v*delta
		chip.v.y += 180*delta
	chips = chips.filter(func(chip): return chip.life>0)
	light.energy = maxf(0,1-summon_age/1.0)*(0.12+(1-ambient)*0.35)
	light.position = Vector2(0,-24)+direction*target_distance*(sin(progress*PI)*0.5+0.4)
	queue_redraw()

func _draw() -> void:
	if summon_age < 1.0:
		var phase = 0 if progress<0.2 else (1 if progress<0.52 else (2 if progress<0.74 else 3))
		var frame = Directional.sheet_frame("res://assets/art/native/axe.png",phase,Directional.direction_index(direction),4,4,Vector2i(24,28))
		var windup = Vector2(30 if direction.x>=0 else -30,-30)-direction*10
		var strike = Vector2(0,-18)+direction*target_distance
		var point = windup.lerp(strike,smoothstep(0.36,0.64,progress))
		point = (point/2).round()*2
		var alpha = smoothstep(0,0.15,progress)*(1-smoothstep(0.78,1.0,summon_age))
		if frame != null:
			draw_texture_rect(frame,Rect2(point-Vector2(24,28),Vector2(48,56)),false,Color(0.85,1,0.97,alpha*0.8))
		if progress<0.25:
			for i in range(6):
				var angle = i*TAU/6+hover_time*2
				var mote = windup+Vector2(cos(angle),sin(angle))*18*(1-progress)
				draw_rect(Rect2((mote/2).round()*2,Vector2(2,2)),Color(0.65,1,0.9,alpha))
	for chip in chips:
		var color = Color("a0bd65") if chip.leaf else Color("d8ab6c")
		color.a = chip.life/0.4
		draw_rect(Rect2((chip.p/2).round()*2,Vector2(4,2)),color)