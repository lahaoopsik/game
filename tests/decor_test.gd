extends SceneTree
const State = preload("res://scripts/world_state.gd")
func _initialize() -> void:
	var state = State.new()
	var portable: Dictionary = {}
	for prop in state.decorations:
		if prop.family=="micro" and prop.variant==0:
			portable=prop
			break
	assert(not portable.is_empty())
	var item = state.Decor.item_id(portable.family,int(portable.variant))
	var target = Vector2(portable.x,portable.y)
	var original = state.decorations.size()
	assert(state.command("chop",target+Vector2(30,0),target).begins_with("Разобрано"))
	assert(state.decorations.size()==original-1 and state.inventory.count(item)==1)
	var spot = Vector2(1224,888)
	assert(state.command("place_decor",spot+Vector2(80,0),spot,{"item":item,"rotation":3})=="Предмет установлен")
	assert(state.inventory.count(item)==0 and state.decorations.size()==original)
	assert(state.decorations[-1].rotation==3)
	assert(state.command("place_decor",spot+Vector2(80,0),spot,{"item":item})=="Предмета нет в инвентаре")
	var restored = State.new()
	assert(restored.restore(state.snapshot(spot)))
	assert(restored.decorations[-1].rotation==3)
	assert(restored.decorations.size()==state.decorations.size())
	assert(not state.Decor.portable("micro",9))
	assert(not state.Decor.portable("micro",8))
	print("PASS: dismantle, return inventory item, place, rotation, no duplication, persistence and natural exclusions")
	quit()
