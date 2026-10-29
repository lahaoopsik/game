extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.player.position=Vector2(2120,1930)
	var event=InputEventKey.new()
	event.physical_keycode=KEY_E
	event.pressed=true
	scene._unhandled_input(event)
	assert(scene.indoors and scene.state.location=="chief_tent")
	assert(scene.environment.indoors and not scene.entities.visible)
	assert(scene.obstacles.process_mode==Node.PROCESS_MODE_DISABLED)
	var position=scene.player.position
	var snapshot=scene.state.snapshot(position)
	assert(snapshot.location=="chief_tent")
	var item="prop:micro:0"
	scene.state.inventory.add(item,1)
	assert(scene.state.command("place_decor",Vector2(330,300),Vector2(280,300),{"item":item,"rotation":2})=="Предмет установлен")
	assert(scene.state.decorations[-1].location=="chief_tent")
	scene.rebuild_obstacles()
	assert(scene.obstacles.process_mode==Node.PROCESS_MODE_DISABLED)
	var saves=preload("res://scripts/save_store.gd")
	saves.PATH=ProjectSettings.globalize_path("res://.godot/interior-test.json")
	scene.save_world()
	scene.leave_tent()
	scene.load_world(true)
	assert(scene.indoors and scene.state.location=="chief_tent")
	assert(scene.outside_position==Vector2(2120,1930))
	DirAccess.remove_absolute(saves.PATH)
	scene.player.position=Vector2(480,595)
	scene._unhandled_input(event)
	assert(not scene.indoors and scene.state.location=="outside")
	assert(scene.player.position==Vector2(2120,1930))
	assert(scene.obstacles.process_mode==Node.PROCESS_MODE_INHERIT)
	print("PASS: E entry and exit, separate bounds and collision worlds, interior placement and saved room location")
	quit()
