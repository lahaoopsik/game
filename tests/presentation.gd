extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var player = scene.player
	for direction in [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]:
		player.facing = direction
		player._physics_process(0.016)
		assert(player.sprite.texture != null)
		assert(player.sprite.flip_h == (direction == Vector2.LEFT))
	player.weapon.attack(Vector2.RIGHT, true)
	player.weapon.register_hit("wood")
	assert(player.weapon.chips.size() == 10)
	player.weapon._process(0.125)
	assert(player.weapon.progress > 0 and player.weapon.progress < 1)
	player.weapon._process(2.0)
	assert(player.weapon.chips.is_empty())
	assert(player.weapon.light.energy == 0)
	scene.environment.phase = 0.5
	scene.environment.update_light()
	assert(scene.environment.tint.color.r > 0.95)
	scene.environment.phase = 0.95
	scene.environment.advance_quarter_day()
	assert(absf(scene.environment.phase - 0.20) < 0.001)
	var saved = scene.environment.snapshot()
	scene.environment.phase = 0.6
	scene.environment.restore(saved)
	assert(absf(scene.environment.phase - 0.20) < 0.001)
	assert(scene.environment.tint.color.r < 0.4)
	assert(player.RUN_MULTIPLIER > 1.0 and player.WALK_SPEED == 230.0)
	scene.interface.set_inventory_open(true)
	assert(scene.interface.inventory_panel.visible and player.input_locked)
	scene.interface.set_inventory_open(false)
	assert(not player.input_locked)
	scene.interface.set_map_open(true)
	assert(scene.interface.map_panel.visible and player.input_locked)
	scene.interface.set_map_open(false)
	scene.interface.set_menu_open(true)
	assert(paused)
	scene.interface.set_menu_open(false)
	assert(not paused)
	print("PASS: directional sprites, spectral summon, hit particles, fade, day/night wrap and time restore")
	quit()
