extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var tree: Dictionary={}
	for candidate in scene.state.trees:
		if candidate.hp==3:
			tree=candidate
			break
	assert(not tree.is_empty())
	var p=Vector2(tree.x,tree.y)
	scene.player.position=p+Vector2(0,80)
	scene.pending_chop={"target":p}
	scene.player.weapon.attack(Vector2.UP,false,80)
	scene.player.weapon._process(0.2)
	assert(tree.hp==3,"Tree must not react before contact")
	scene.player.weapon._process(0.2)
	assert(tree.hp==2,"Tree reacts at contact")
	var found=false
	for view in scene.entities.get_children():
		if view.get_script()==preload("res://scripts/world_art.gd") and view.kind=="tree" and view.data.id==tree.id:
			view._process(0.01)
			assert(view.hit_time>0)
			found=true
	assert(found)
	scene.player.weapon._process(0.4)
	assert(tree.hp==2,"One impact per attack")
	print("PASS: no early damage, exact impact, tree shake and one hit per animation")
	quit()
