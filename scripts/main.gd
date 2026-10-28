extends Node2D
const State = preload("res://scripts/world_state.gd")
const Player = preload("res://scripts/player.gd")
const Saves = preload("res://scripts/save_store.gd")
const Art = preload("res://scripts/art.gd")
const WorldArt = preload("res://scripts/world_art.gd")
var state = State.new()
var player: CharacterBody2D
var obstacles: Node2D
var hud: Label
var status: Label
var placement = false
var cooldown = 0.0
var autosave = 0.0
var flowers: Array = []
var entities: Node2D
var visual_time = 0.0
var environment: Node
var ground_view: Sprite2D
var interface: CanvasLayer

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ground_view = preload("res://scripts/terrain_view.gd").new()
	ground_view.terrain = state.terrain
	add_child(ground_view)
	environment = preload("res://scripts/environment.gd").new()
	add_child(environment)
	add_child(preload("res://scripts/map_scenery.gd").new())
	entities = Node2D.new()
	entities.y_sort_enabled = true
	add_child(entities)
	player = Player.new()
	player.position = Vector2(1200, 900)
	entities.add_child(player)
	var atmosphere = preload("res://scripts/atmosphere.gd").new()
	atmosphere.environment = environment
	atmosphere.z_index = 20
	add_child(atmosphere)
	var camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 2400
	camera.limit_bottom = 1800
	player.add_child(camera)
	flowers = preload("res://scripts/valley_layout.gd").grass_positions()
	var ui = preload("res://scripts/pixel_ui.gd").new()
	interface = ui
	add_child(ui)
	ui.inventory_toggled.connect(func(opened): player.input_locked = opened)
	hud = ui.resources
	status = ui.message
	load_world(false)
	rebuild_obstacles()
	get_tree().auto_accept_quit = false

func _unhandled_input(event: InputEvent) -> void:
	if interface.inventory_panel.visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_B: placement = not placement
			KEY_ESCAPE: placement = false
			KEY_E: act("interact")
			KEY_F5: save_world()
			KEY_F9: load_world(true)
			KEY_F6: environment.advance_quarter_day()
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
		player.facing = (get_global_mouse_position() - player.position).normalized()
		player.weapon.attack(player.facing, status.text.begins_with("Удар") or status.text.begins_with("+5"))
	rebuild_obstacles()

func _process(delta: float) -> void:
	visual_time += delta
	player.weapon.ambient = environment.tint.color.r
	var sun_angle = (environment.phase - 0.25) * TAU
	var sun_direction = Vector2(cos(sun_angle), 0.65).normalized()
	ground_view.material.set_shader_parameter("sun_direction", sun_direction)
	for visual in entities.get_children():
		if visual != player:
			visual.sun_direction = sun_direction
			visual.sun_length = 1.0 + absf(cos(sun_angle)) * 1.2
			visual.sun_strength = clampf(environment.tint.color.r, 0.25, 1.0)
	cooldown = maxf(0, cooldown - delta)
	autosave += delta
	if autosave >= 30:
		save_world()
		autosave = 0
	hud.text = str(state.wood)
	queue_redraw()

func rebuild_obstacles() -> void:
	ground_view.refresh()
	for child in entities.get_children():
		if child != player:
			entities.remove_child(child)
			child.queue_free()
	for t in state.trees:
		add_visual(Vector2(t.x, t.y), "tree", t)
	for b in state.buildings:
		add_visual(Vector2(b.x, b.y), "bench", b)
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
	for y in range(state.terrain.SIZE.y):
		for x in range(state.terrain.SIZE.x):
			if state.terrain.material_at(Vector2i(x, y)) == state.terrain.Kind.WATER:
				add_obstacle(Vector2(x * 48 + 24, y * 48 + 24), Vector2(48, 48))
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
	var data = state.snapshot(player.position)
	data["environment"] = environment.snapshot()
	var result = Saves.save_game(data)
	status.text = "Долина сохранена" if result == OK else "Ошибка сохранения: %s" % error_string(result)

func load_world(show_message: bool) -> void:
	var data = Saves.load_game()
	if state.restore(data):
		var legacy_map = data.get("layout", "") != state.Layout.ID
		if legacy_map and FileAccess.file_exists(Saves.PATH) and not FileAccess.file_exists(Saves.PATH + ".before-authored.json"):
			DirAccess.copy_absolute(Saves.PATH, Saves.PATH + ".before-authored.json")
		environment.restore(data.get("environment", {}))
		player.position = Vector2(data.player[0], data.player[1])
		if state.terrain.material_at(Vector2i((player.position / 48).floor())) == state.terrain.Kind.WATER:
			player.position = Vector2(1200, 900)
		rebuild_obstacles()
		status.text = "Карта обновлена · ресурсы и постройки сохранены" if legacy_map else "Долина загружена"
	elif show_message:
		status.text = "Сохранение отсутствует или повреждено"

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_world()
		get_tree().quit()

func _draw() -> void:
	for p in flowers:
		if absf(p.x - State.river_x(p.y)) > 68:
			draw_line(p, p + Vector2(2, -5), Color("75a461"), 2)
			if int(p.x) % 4 == 0:
				draw_circle(p + Vector2(1, -6), 2.5, Color("fff0bc"))
			else:
				var wind = sin(visual_time * 1.6 + p.x * 0.03 + p.y * 0.01) * 3
				draw_line(p, p + Vector2(2 + wind, -9), Color("709353"), 2)
				draw_line(p + Vector2(3, 0), p + Vector2(4 + wind, -6), Color("b0c17a"), 2)
	for y in range(20, 1800, 46):
		var ripple_y = fmod(y + visual_time * 12, 1800)
		var ripple_x = State.river_x(ripple_y) + sin(y * 0.8 + visual_time) * 27
		draw_line(Vector2(ripple_x - 7, ripple_y), Vector2(ripple_x + 7, ripple_y), Color(0.8, 0.95, 0.91, 0.48), 2)
	if placement:
		var p = (get_global_mouse_position() / State.GRID).floor() * State.GRID + Vector2.ONE * State.GRID / 2
		var valid = state.can_place(p) and player.position.distance_to(p) <= 210 and player.position.distance_to(p) >= 60
		var tint = Color(0.6, 1, 0.8, 0.5) if valid else Color(1, 0.4, 0.3, 0.5)
		for x in range(-3, 4):
			for y in range(-3, 4):
				draw_rect(Rect2(p + Vector2(x, y) * 48 - Vector2(24, 24), Vector2(48, 48)), Color(1, 1, 1, 0.16), false)
		Art.draw_asset(self, 3, 0, p - Vector2(58, 92), Vector2(116, 116), tint)

func add_visual(p: Vector2, kind: String, data: Dictionary) -> void:
	var visual = WorldArt.new()
	visual.position = p
	visual.kind = kind
	visual.data = data
	visual.observer = player
	entities.add_child(visual)
