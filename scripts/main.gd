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
var shadows: Node2D
var placement_rotation = 0
var pending_chop: Dictionary = {}
var indoors = false
var room: Node2D
var outside_position = Vector2(2120,1920)

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	y_sort_enabled = true
	ground_view = preload("res://scripts/terrain_view.gd").new()
	ground_view.terrain = state.terrain
	add_child(ground_view)
	var relief = preload("res://scripts/terrain_relief.gd").new()
	relief.terrain = state.terrain
	add_child(relief)
	shadows = preload("res://scripts/tree_shadows.gd").new()
	shadows.state = state
	add_child(shadows)
	var bridge_view = preload("res://scripts/bridge_view.gd").new()
	bridge_view.position = State.Layout.bridge_center()
	add_child(bridge_view)
	environment = preload("res://scripts/environment.gd").new()
	add_child(environment)
	add_child(preload("res://scripts/map_scenery.gd").new())
	entities = Node2D.new()
	entities.y_sort_enabled = true
	add_child(entities)
	player = Player.new()
	player.position = Vector2(1200, 900)
	entities.add_child(player)
	player.weapon.impact.connect(apply_chop_impact)
	var grass_view = preload("res://scripts/grass_view.gd").new()
	grass_view.state = state
	add_child(grass_view)
	var atmosphere = preload("res://scripts/atmosphere.gd").new()
	atmosphere.environment = environment
	atmosphere.z_index = 20
	add_child(atmosphere)
	var camera = preload("res://scripts/pixel_camera.gd").new()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(State.WORLD_SIZE.x)
	camera.limit_bottom = int(State.WORLD_SIZE.y)
	player.add_child(camera)
	flowers = preload("res://scripts/valley_layout.gd").grass_positions()
	var ui = preload("res://scripts/pixel_ui.gd").new()
	interface = ui
	add_child(ui)
	environment.clock = ui.clock_label
	ui.inventory_toggled.connect(func(opened): player.input_locked = opened)
	ui.world_state = state
	ui.save_requested.connect(save_world)
	ui.load_requested.connect(func(): load_world(true))
	ui.quit_requested.connect(func(): save_world(); get_tree().quit())
	hud = ui.resources
	status = ui.message
	rebuild_obstacles()
	load_world(false)
	rebuild_obstacles()
	get_tree().auto_accept_quit = false
	var wildlife = preload("res://scripts/creature_population.gd").new()
	wildlife.world = self
	add_child(wildlife)
	if indoors:
		wildlife.hide()

func _unhandled_input(event: InputEvent) -> void:
	if interface.is_modal_open():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_B: placement = not placement
			KEY_R: placement_rotation = (placement_rotation + 1) % 4
			KEY_ESCAPE: placement = false
			KEY_E:
				if not indoors and player.position.distance_to(Vector2(2120,1900))<80:
					enter_tent()
				elif indoors and player.position.distance_to(Vector2(480,600))<75:
					leave_tent()
				else:
					act("interact")
			KEY_F5: save_world()
			KEY_F9: load_world(true)
			KEY_F6: environment.advance_quarter_day()
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			placement = false
			interface.select_slot(-1)
		if event.button_index == MOUSE_BUTTON_LEFT:
			act("place" if placement else ("place_decor" if selected_decor_item() != "" else "chop"))

func act(action: String) -> void:
	if cooldown > 0:
		return
	if action == "chop":
		var target = get_global_mouse_position()
		var direction = (target-player.position).normalized()
		pending_chop = {"target":target}
		player.facing = direction
		player.weapon.attack(direction,false,player.position.distance_to(target))
		cooldown = player.weapon.DURATION
		return
	cooldown = 0.25
	var tree_count = state.trees.size()
	var decor_count = state.decorations.size()
	status.text = state.command(action, player.position, get_global_mouse_position(), {"item":selected_decor_item(),"rotation":placement_rotation})
	if action == "chop":
		player.swing = 0.22
		player.facing = (get_global_mouse_position() - player.position).normalized()
		player.weapon.attack(player.facing, status.text.begins_with("Удар") or status.text.begins_with("+5"))
	if action != "chop" or tree_count != state.trees.size() or decor_count != state.decorations.size():
		rebuild_obstacles()

func _process(delta: float) -> void:
	visual_time += delta
	player.weapon.ambient = environment.tint.color.r
	var sun_angle = (environment.phase - 0.25) * TAU
	var sun_direction = Vector2(cos(sun_angle), 0.65).normalized()
	ground_view.material.set_shader_parameter("sun_direction", sun_direction)
	shadows.sun_direction = sun_direction
	shadows.sun_length = 1.0 + absf(cos(sun_angle)) * 1.2
	shadows.sun_strength = clampf(environment.tint.color.r, 0.25, 1.0)
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
	interface.inventory_model = state.inventory
	interface.player_position = outside_position if indoors else player.position
	interface.time_phase=environment.phase
	if not indoors and player.position.distance_to(Vector2(2120,1900))<80:
		interface.action_hint.text="E — ВОЙТИ В ПАЛАТКУ"
	elif indoors and player.position.distance_to(Vector2(480,600))<75:
		interface.action_hint.text="E — ВЫЙТИ В ДОЛИНУ"
	elif placement or selected_decor_item()!="":
		interface.action_hint.text="R — ПОВОРОТ   ЛКМ — ПОСТАВИТЬ   ПКМ — ОТМЕНА"
	else:
		interface.action_hint.text="TAB ИНВЕНТАРЬ   M КАРТА   ESC МЕНЮ"
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
		if b.get("location","outside")!="outside":
			continue
		add_visual(Vector2(b.x, b.y), "bench", b)
	for decoration in state.decorations:
		if decoration.get("location","outside")!="outside":
			continue
		var decor_view = preload("res://scripts/decor_view.gd").new()
		decor_view.data = decoration
		decor_view.state = state
		decor_view.position = Vector2(decoration.x, decoration.y)
		decor_view.environment = environment
		entities.add_child(decor_view)
	for village_prop in State.Layout.VILLAGE:
		if village_prop.z >= 4:
			continue
		var prop = preload("res://scripts/goblin_camp_prop.gd").new()
		prop.position = Vector2(village_prop.x, village_prop.y)
		prop.variant = int(village_prop.z)
		prop.environment = environment
		entities.add_child(prop)
	if is_instance_valid(obstacles):
		remove_child(obstacles)
		obstacles.queue_free()
	obstacles = Node2D.new()
	add_child(obstacles)
	for t in state.trees:
		add_obstacle(Vector2(t.x, t.y), Vector2(30, 26))
	for b in state.buildings:
		if b.work >= 4:
			if b.get("location","outside")!="outside":
				continue
			add_obstacle(Vector2(b.x, b.y), Vector2(48,76) if int(b.get("rotation",0))%2==1 else Vector2(76,48))
	for prop in state.decorations:
		if prop.get("location","outside")!="outside":
			continue
		if prop.family == "fence":
			var vertical = (int(prop.variant) + int(prop.get("rotation",0))) % 2 == 1
			add_obstacle(Vector2(prop.x, prop.y - 8), Vector2(18,46) if vertical else Vector2(88,12))
		elif prop.family in ["lamp","torch"]:
			add_obstacle(Vector2(prop.x, prop.y),Vector2(18,14))
		elif prop.family == "camp" and prop.variant == 6:
			add_obstacle(Vector2(prop.x,prop.y-6),Vector2(80,12))
	for prop in State.Layout.VILLAGE:
		if prop.z < 4:
			add_obstacle(Vector2(prop.x, prop.y - 25), Vector2(160, 55) if prop.z == 0 else Vector2(85, 40))
	for edge in state.terrain.cliff_edges:
		add_obstacle(edge.p, edge.size)
	var bridge = State.Layout.bridge_center()
	add_obstacle(bridge + Vector2(0, -44), Vector2(242, 10))
	add_obstacle(bridge + Vector2(0, 44), Vector2(242, 10))
	for y in range(state.terrain.SIZE.y):
		for x in range(state.terrain.SIZE.x):
			if state.terrain.material_at(Vector2i(x, y)) == state.terrain.Kind.WATER:
				var p = Vector2(x * 48 + 24, y * 48 + 24)
				if not State.Layout.is_bridge(p):
					add_obstacle(p, Vector2(48, 48))
	if indoors:
		entities.hide()
		obstacles.process_mode=Node.PROCESS_MODE_DISABLED
		obstacles.hide()
		if is_instance_valid(room):
			room.refresh()
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
	data["outside_position"]=[outside_position.x,outside_position.y]
	var result = Saves.save_game(data)
	status.text = "Долина сохранена" if result == OK else "Ошибка сохранения: %s" % error_string(result)

func load_world(show_message: bool) -> void:
	var data = Saves.load_game()
	if state.restore(data):
		var saved_location=state.location
		if indoors:
			leave_tent()
		state.location=saved_location
		var saved_return=data.get("outside_position",[2120,1920])
		outside_position=Vector2(saved_return[0],saved_return[1])
		var legacy_map = data.get("layout", "") != state.Layout.ID
		if legacy_map and FileAccess.file_exists(Saves.PATH) and not FileAccess.file_exists(Saves.PATH + ".before-authored.json"):
			DirAccess.copy_absolute(Saves.PATH, Saves.PATH + ".before-authored.json")
		environment.restore(data.get("environment", {}))
		player.position = Vector2(data.player[0], data.player[1])
		if saved_location=="chief_tent":
			enter_tent(true,player.position)
		elif state.terrain.material_at(Vector2i((player.position / 48).floor())) == state.terrain.Kind.WATER:
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
	if indoors:
		return
	for p in flowers:
		if absf(p.x - State.river_x(p.y)) > 68:
			draw_line(p, p + Vector2(2, -5), Color("75a461"), 2)
			if int(p.x) % 4 == 0:
				draw_circle(p + Vector2(1, -6), 2.5, Color("fff0bc"))
			else:
				var wind = sin(visual_time * 1.6 + p.x * 0.03 + p.y * 0.01) * 3
				draw_line(p, p + Vector2(2 + wind, -9), Color("709353"), 2)
				draw_line(p + Vector2(3, 0), p + Vector2(4 + wind, -6), Color("b0c17a"), 2)
	for y in range(20, int(State.WORLD_SIZE.y), 46):
		var ripple_y = fmod(y + visual_time * 12, State.WORLD_SIZE.y)
		if absf(ripple_y - 1050) < 64:
			continue
		var ripple_x = State.river_x(ripple_y) + sin(y * 0.8 + visual_time) * 27
		draw_line(Vector2(ripple_x - 7, ripple_y), Vector2(ripple_x + 7, ripple_y), Color(0.8, 0.95, 0.91, 0.48), 2)
	if placement:
		var p = (get_global_mouse_position() / State.GRID).floor() * State.GRID + Vector2.ONE * State.GRID / 2
		var valid = state.can_place(p) and player.position.distance_to(p) <= 210 and player.position.distance_to(p) >= 60
		var tint = Color(0.6, 1, 0.8, 0.5) if valid else Color(1, 0.4, 0.3, 0.5)
		for x in range(-3, 4):
			for y in range(-3, 4):
				draw_rect(Rect2(p + Vector2(x, y) * 48 - Vector2(24, 24), Vector2(48, 48)), Color(1, 1, 1, 0.16), false)
		draw_set_transform(p)
		var texture = preload("res://scripts/directional_art.gd").prop("bench",0,placement_rotation)
		if texture != null:
			Art.draw_oriented(self,texture,placement_rotation,tint)
		draw_set_transform(Vector2.ZERO)
	elif selected_decor_item() != "":
		var prop = state.Decor.parse(selected_decor_item())
		var p = (get_global_mouse_position() / State.GRID).floor() * State.GRID + Vector2.ONE * State.GRID / 2
		var valid = state.can_place_decor(p) and player.position.distance_to(p) <= 180
		draw_set_transform(p)
		Art.draw_oriented(self, Art.prop_texture(prop.family,prop.variant,0,placement_rotation),placement_rotation,Color(0.7,1,0.8,0.6) if valid else Color(1,0.4,0.3,0.6))
		draw_set_transform(Vector2.ZERO)

func selected_decor_item() -> String:
	if interface == null or interface.selected_slot < 0:
		return ""
	var entry = state.inventory.hotbar[interface.selected_slot]
	return entry.item if entry is Dictionary and not state.Decor.parse(entry.item).is_empty() else ""

func apply_chop_impact() -> void:
	if pending_chop.is_empty():
		return
	var target: Vector2 = pending_chop.target
	pending_chop.clear()
	var tree_count = state.trees.size()
	var decor_count = state.decorations.size()
	var hit_object: Dictionary = {}
	for prop in state.decorations:
		if state.Decor.portable(prop.family,int(prop.variant)) and target.distance_to(Vector2(prop.x,prop.y)) < 24:
			if prop.get("location","outside")!=state.location:
				continue
			hit_object = {"texture":Art.prop_texture(prop.family,int(prop.variant),0,int(prop.get("rotation",0))),"p":Vector2(prop.x,prop.y),"tree":false}
			break
	if hit_object.is_empty() and not indoors:
		for tree in state.trees:
			if target.distance_to(Vector2(tree.x,tree.y)) < 65:
				hit_object={"texture":Art.tree_texture(int(tree.id)),"p":Vector2(tree.x,tree.y),"tree":true}
				break
	status.text = state.command("chop",player.position,target)
	interface.message_age = 0
	if status.text.begins_with("Удар") or status.text.begins_with("+5") or status.text.begins_with("Разобрано") or status.text == "Трава срезана":
		player.weapon.register_hit("grass" if status.text=="Трава срезана" else "wood")
	if tree_count != state.trees.size() or decor_count != state.decorations.size():
		if not hit_object.is_empty():
			var echo = preload("res://scripts/hit_echo.gd").new()
			echo.texture = hit_object.texture
			echo.tree = hit_object.tree
			echo.position = hit_object.p
			echo.sign_x = signf(player.weapon.direction.x) if absf(player.weapon.direction.x)>0.1 else 1.0
			add_child(echo)
		rebuild_obstacles()

func add_visual(p: Vector2, kind: String, data: Dictionary) -> void:
	var visual = WorldArt.new()
	visual.position = p
	visual.kind = kind
	visual.data = data
	visual.observer = player
	entities.add_child(visual)

func add_landmark(p: Vector2, kind: String, variant: int) -> void:
	var prop = preload("res://scripts/landmark_prop.gd").new()
	prop.position = p
	prop.kind = kind
	prop.variant = variant
	prop.environment = environment
	entities.add_child(prop)

func enter_tent(from_save: bool=false, spawn: Vector2=Vector2(480,565)) -> void:
	if indoors:
		return
	pending_chop.clear()
	player.weapon.progress=1
	if not from_save:
		outside_position=player.global_position
	player.reparent(self)
	for child in get_children():
		if child is Node2D and child!=player:
			child.hide()
	obstacles.process_mode=Node.PROCESS_MODE_DISABLED
	indoors=true
	state.location="chief_tent"
	environment.indoors=true
	room=preload("res://scripts/tent_room.gd").new()
	room.state=state
	room.environment=environment
	add_child(room)
	player.indoors=true
	player.movement_bounds=Rect2(30,40,900,580)
	player.position=spawn
	for child in player.get_children():
		if child is Camera2D:
			child.zoom=Vector2.ONE
			child.limit_left=-160
			child.limit_top=-80
			child.limit_right=1120
			child.limit_bottom=720
			child.update_camera()
	status.text="Главная палатка · E у входа — выйти"
	queue_redraw()

func leave_tent() -> void:
	if not indoors:
		return
	pending_chop.clear()
	if is_instance_valid(room):
		remove_child(room)
		room.queue_free()
	indoors=false
	state.location="outside"
	environment.indoors=false
	player.indoors=false
	player.movement_bounds=Rect2(Vector2.ZERO,State.WORLD_SIZE)
	player.reparent(entities)
	player.position=outside_position
	for child in get_children():
		if child is Node2D:
			child.show()
	obstacles.process_mode=Node.PROCESS_MODE_INHERIT
	for child in player.get_children():
		if child is Camera2D:
			child.zoom=Vector2.ONE
			child.limit_left=0
			child.limit_top=0
			child.limit_right=int(State.WORLD_SIZE.x)
			child.limit_bottom=int(State.WORLD_SIZE.y)
			child.update_camera()
	status.text="Солнечная долина"
	queue_redraw()
