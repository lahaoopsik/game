extends SceneTree
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	scene.state.inventory = preload("res://scripts/inventory.gd").new()
	scene.state.inventory.add("wood", 7)
	scene.interface.inventory_model = scene.state.inventory
	scene.interface.set_inventory_open(true)
	for i in range(4):
		await process_frame
	var source = scene.interface.slot_views[0]
	var target = scene.interface.slot_views[9]
	var a = source.get_global_rect().get_center()
	var b = target.get_global_rect().get_center()
	motion(a, Vector2.ZERO, false)
	button(a, true)
	await process_frame
	motion(a + Vector2(24, -20), Vector2(24, -20), true)
	await process_frame
	motion(b, b - a, true)
	await process_frame
	button(b, false)
	await process_frame
	assert(scene.state.inventory.hotbar[0] == null, "Mouse drag must remove the source stack")
	assert(scene.state.inventory.pocket[0].count == 7, "Mouse drop must reach reserve slot")
	print("PASS: real viewport mouse press, drag and drop from hotbar to reserve")
	quit()

func motion(p: Vector2, relative: Vector2, pressed: bool) -> void:
	var event = InputEventMouseMotion.new()
	event.position = p
	event.global_position = p
	event.relative = relative
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	root.push_input(event)

func button(p: Vector2, pressed: bool) -> void:
	var event = InputEventMouseButton.new()
	event.position = p
	event.global_position = p
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	root.push_input(event)
