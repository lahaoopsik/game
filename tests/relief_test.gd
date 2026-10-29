extends SceneTree
func _initialize() -> void:
	var state=preload("res://scripts/world_state.gd").new()
	assert(state.grass.size()>700)
	var quadrants={}
	var ids={}
	for clump in state.grass:
		assert(not ids.has(clump.id))
		ids[clump.id]=true
		var p=Vector2(clump.x,clump.y)
		assert(state.terrain.material_at(Vector2i(p/48))==0)
		quadrants[Vector2i(p/Vector2(1044,780))]=true
	assert(quadrants.size()>=12)
	var levels={}
	for y in range(65):
		for x in range(87):
			levels[state.terrain.elevation_at(Vector2i(x,y))]=true
	assert(levels.size()==5)
	assert(state.terrain.is_ramp(Vector2(1200,760)))
	state.cleared_grass.append(state.grass[0].id)
	var count=state.grass.size()
	state.reset_grass()
	assert(state.grass.size()==count-1)
	print("PASS: distributed grass, stable IDs and clearing, 5 elevation levels and path ramps")
	quit()
