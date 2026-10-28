extends Node2D
const State = preload("res://scripts/world_state.gd")
const Player = preload("res://scripts/player.gd")
const Saves = preload("res://scripts/save_store.gd")
var state = State.new()
var player: CharacterBody2D
var obstacles: Node2D
var hud: Label
var status: Label
var placement = false
var cooldown = 0.0
var autosave = 0.0
var flowers: Array = []

func _ready() -> void:
	player = Player.new()
	player.position = Vector2(1200, 900)
	add_child(player)
	var camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 2400
	camera.limit_bottom = 1800
	player.add_child(camera)
	var rng = RandomNumberGenerator.new()
	rng.seed = 102
	for i in range(600):
		flowers.append(Vector2(rng.randf_range(20, 2380), rng.randf_range(20, 1780)))
	var layer = CanvasLayer.new()
	add_child(layer)
	var panel = PanelContainer.new()
	panel.position = Vector2(20, 20)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(panel)
	var style = StyleBoxFlat.new()
	style.bg_color = Color("233b36")
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 15
	style.content_margin_bottom = 15
	style.set_corner_radius_all(12)
	panel.add_theme_stylebox_override("panel", style)
	var box = VBoxContainer.new()
	panel.add_child(box)
	var title = Label.new()
	title.text = "СОЛНЕЧНАЯ ДОЛИНА / прототип 01"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("ffe3a4"))
	box.add_child(title)
	hud = Label.new()
	box.add_child(hud)
	var help = Label.new()
	help.text = "WASD / стрелки — движение\nЛКМ по стволу — магический топорик\nB — чертёж верстака · ЛКМ — разместить\nE у чертежа под курсором — внести дерево / строить\nEsc / ПКМ — отмена · F5 — сохранить · F9 — загрузить"
	box.add_child(help)
	status = Label.new()
	status.text = "Добудь древесину и построй верстак"
	box.add_child(status)
	load_world(false)
	rebuild_obstacles()
	get_tree().auto_accept_quit = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_B: placement = not placement
			KEY_ESCAPE: placement = false
			KEY_E: act("interact")
			KEY_F5: save_world()
			KEY_F9: load_world(true)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			placement = false
		if event.button_index == MOUSE_BUTTON_LEFT:
			act("place" if placement else "chop")

func act(action: String) -> void:
	if cooldown > 0:
		return
	cooldown = 0.25
	status.text = state.command(action, player.position, get_global_mouse_position())
	if action == "chop":
		player.swing = 0.22
	rebuild_obstacles()

func _process(delta: float) -> void:
	cooldown = maxf(0, cooldown - delta)
	autosave += delta
	if autosave >= 30:
		save_world()
		autosave = 0
	hud.text = "Древесина: %d | Верстак: %d дерева + 4 работы%s" % [state.wood, State.COST, " | ЧЕРТЁЖ" if placement else ""]
	queue_redraw()

func rebuild_obstacles() -> void:
	if is_instance_valid(obstacles):
		remove_child(obstacles)
		obstacles.queue_free()
	obstacles = Node2D.new()
	add_child(obstacles)
	for t in state.trees:
		add_obstacle(Vector2(t.x, t.y), Vector2(30, 26))
	for b in state.buildings:
		if b.work >= 4:
			add_obstacle(Vector2(b.x, b.y), Vector2(76, 48))
	for y in range(0, 1800, 24):
		add_obstacle(Vector2(State.river_x(y), y), Vector2(92, 30))

func add_obstacle(p: Vector2, size: Vector2) -> void:
	var body = StaticBody2D.new()
	body.position = p
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	obstacles.add_child(body)

func save_world() -> void:
	var result = Saves.save_game(state.snapshot(player.position))
	status.text = "Долина сохранена" if result == OK else "Ошибка сохранения: %s" % error_string(result)

func load_world(show_message: bool) -> void:
	var data = Saves.load_game()
	if state.restore(data):
		player.position = Vector2(data.player[0], data.player[1])
		rebuild_obstacles()
		status.text = "Долина загружена"
	elif show_message:
		status.text = "Сохранение отсутствует или повреждено"

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_world()
		get_tree().quit()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, State.WORLD_SIZE), Color("92b979"))
	for p in flowers:
		if absf(p.x - State.river_x(p.y)) > 68:
			draw_line(p, p + Vector2(2, -5), Color("75a461"), 2)
			if int(p.x) % 4 == 0:
				draw_circle(p + Vector2(1, -6), 2.5, Color("fff0bc"))
	var bank = PackedVector2Array()
	for y in range(-20, 1840, 16):
		bank.append(Vector2(State.river_x(y), y))
	draw_polyline(bank, Color("c5c594"), 126, true)
	draw_polyline(bank, Color("70bcca"), 98, true)
	draw_polyline(bank, Color("98d3d5"), 5, true)
	for t in state.trees:
		var p = Vector2(t.x, t.y)
		draw_circle(p + Vector2(5, 3), 30, Color(0.15, 0.28, 0.15, 0.2))
		draw_rect(Rect2(p + Vector2(-9, -39), Vector2(18, 44)), Color("805b40"))
		draw_circle(p + Vector2(0, -57), 37, Color("3d7750"))
		draw_circle(p + Vector2(-18, -68), 26, Color("57945b"))
		draw_circle(p + Vector2(14, -82), 29, Color("6ca563"))
		if t.hp < 3:
			draw_line(p + Vector2(-15, 12), p + Vector2(-15 + t.hp * 10, 12), Color("ffe1a1"), 4)
	for b in state.buildings:
		var p = Vector2(b.x, b.y)
		var rect = Rect2(p - Vector2(40, 28), Vector2(80, 56))
		if b.work < 4:
			draw_rect(rect, Color(0.6, 0.9, 1.0, 0.25))
			draw_rect(rect, Color("d7f6ee"), false, 2)
			var progress = float(b.wood) / State.COST if b.wood < State.COST else float(b.work) / 4
			draw_line(p + Vector2(-38, 36), p + Vector2(-38 + 76 * progress, 36), Color("ffe2a2"), 5)
		else:
			draw_line(p + Vector2(-27, -3), p + Vector2(-27, 27), Color("6b4b35"), 8)
			draw_line(p + Vector2(27, -3), p + Vector2(27, 27), Color("6b4b35"), 8)
			draw_rect(rect, Color("ad7949"))
			draw_rect(Rect2(p - Vector2(43, 31), Vector2(86, 13)), Color("d6ab70"))
	if placement:
		var p = (get_global_mouse_position() / State.GRID).floor() * State.GRID + Vector2.ONE * State.GRID / 2
		var valid = state.can_place(p) and player.position.distance_to(p) <= 210 and player.position.distance_to(p) >= 60
		var tint = Color(0.6, 1, 0.8, 0.5) if valid else Color(1, 0.4, 0.3, 0.5)
		for x in range(-3, 4):
			for y in range(-3, 4):
				draw_rect(Rect2(p + Vector2(x, y) * 48 - Vector2(24, 24), Vector2(48, 48)), Color(1, 1, 1, 0.16), false)
		draw_rect(Rect2(p - Vector2(40, 28), Vector2(80, 56)), tint)
