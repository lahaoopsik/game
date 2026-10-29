extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene=load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await physics_frame
	var population: Node
	for child in scene.get_children():
		if child.get_script()==load("res://scripts/creature_population.gd"):
			population=child
	assert(population!=null)
	assert(population.get_child_count()==21)
	var rabbit=population.get_child(0)
	assert(rabbit.sprite.texture!=null)
	scene.player.position=rabbit.position+Vector2(50,0)
	rabbit._physics_process(0.016)
	assert(rabbit.mode=="flee" and rabbit.velocity.x<0)
	for creature in population.get_children():
		assert(scene.state.terrain.material_at(Vector2i(creature.position/48))!=7)
		assert(creature.animation.size()==4)
		assert(creature.active_at(0.5)==(creature.species!=2))
		assert(creature.active_at(0.95))
	scene.enter_tent()
	var before=rabbit.position
	rabbit._physics_process(1)
	assert(rabbit.position==before and not population.visible)
	scene.leave_tent()
	assert(population.visible)
	for step in range(180):
		await physics_frame
	for creature in population.get_children():
		assert(scene.state.terrain.material_at(Vector2i(creature.position/48))!=7)
	print("PASS: 21 inhabitants, animated frames, habitats, flee response, nocturnal moths, interior isolation and dry terrain")
	quit()
