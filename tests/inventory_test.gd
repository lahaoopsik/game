extends SceneTree
const Inventory = preload("res://scripts/inventory.gd")
const State = preload("res://scripts/world_state.gd")

func _initialize() -> void:
	var inventory = Inventory.new()
	for i in range(9):
		assert(inventory.add("item%d" % i, i + 1))
	assert(inventory.add("wood", 5))
	assert(inventory.pocket[0].item == "wood")
	assert(inventory.move("pocket", 0, "hotbar", 1))
	assert(inventory.hotbar[1].item == "wood" and inventory.pocket[0].item == "item1")
	assert(inventory.count("wood") == 5)
	assert(not inventory.move("hotbar", -1, "pocket", 0))
	var copy = Inventory.new()
	assert(copy.restore(inventory.snapshot()))
	assert(copy.hotbar[1].item == "wood" and copy.pocket[0].count == 2)
	assert(copy.add("wood", 3) and copy.count("wood") == 8)
	assert(copy.transfer("hotbar", 1))
	assert(copy.pocket[1].item == "wood")
	var state = State.new()
	assert(state.WORLD_SIZE.x * state.WORLD_SIZE.y > 2400 * 1800 * 3)
	assert(state.terrain.SIZE.x * 48 == state.WORLD_SIZE.x)
	assert(state.terrain.SIZE.y * 48 == state.WORLD_SIZE.y)
	var target: Dictionary = {}
	for clump in state.grass:
		var free = true
		for tree in state.trees:
			if Vector2(clump.x, clump.y).distance_to(Vector2(tree.x, tree.y)) < 80:
				free = false
		if free:
			target = clump
			break
	assert(not target.is_empty())
	var p = Vector2(target.x, target.y)
	assert(state.command("chop", p + Vector2(40, 0), p) == "Трава срезана")
	assert(target.id in state.cleared_grass)
	var restored = State.new()
	assert(restored.restore(state.snapshot(p)))
	assert(target.id in restored.cleared_grass)
	assert(restored.grass.size() == state.grass.size())
	print("PASS: overflow, drag-model move/swap, reserve transfer, inventory save/load, expanded world, cut grass persistence")
	quit()
