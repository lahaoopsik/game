extends RefCounted
const HOTBAR_SIZE = 9
const POCKET_SIZE = 6 # Small prototype reserve; backpack bonuses are not decided.
var hotbar: Array = []
var pocket: Array = []

func _init() -> void:
	hotbar.resize(HOTBAR_SIZE)
	pocket.resize(POCKET_SIZE)
	hotbar.fill(null)
	pocket.fill(null)

func slots(container: String) -> Array:
	return hotbar if container == "hotbar" else pocket

func count(item: String) -> int:
	var total = 0
	for collection in [hotbar, pocket]:
		for entry in collection:
			if entry is Dictionary and entry.item == item:
				total += int(entry.count)
	return total

func add(item: String, amount: int) -> bool:
	if amount <= 0:
		return false
	for collection in [hotbar, pocket]:
		for entry in collection:
			if entry is Dictionary and entry.item == item:
				entry.count += amount
				return true
	for collection in [hotbar, pocket]:
		for i in range(collection.size()):
			if collection[i] == null:
				collection[i] = {"item": item, "count": amount}
				return true
	return false

func set_count(item: String, amount: int) -> void:
	var current = count(item)
	if amount > current:
		add(item, amount - current)
		return
	var remove = current - maxi(0, amount)
	for collection in [hotbar, pocket]:
		for i in range(collection.size()):
			var entry = collection[i]
			if entry is Dictionary and entry.item == item:
				var taken = mini(remove, int(entry.count))
				entry.count -= taken
				remove -= taken
				if entry.count == 0:
					collection[i] = null

func transfer(container: String, index: int) -> bool:
	if container not in ["hotbar", "pocket"]:
		return false
	var source = slots(container)
	var target = pocket if container == "hotbar" else hotbar
	if index < 0 or index >= source.size() or source[index] == null:
		return false
	var entry: Dictionary = source[index]
	for destination in target:
		if destination is Dictionary and destination.item == entry.item:
			destination.count += entry.count
			source[index] = null
			return true
	for i in range(target.size()):
		if target[i] == null:
			target[i] = entry
			source[index] = null
			return true
	return false

func snapshot() -> Dictionary:
	return {"hotbar": hotbar.duplicate(true), "pocket": pocket.duplicate(true)}

func move(source_name: String, source_index: int, target_name: String, target_index: int) -> bool:
	if source_name not in ["hotbar", "pocket"] or target_name not in ["hotbar", "pocket"]:
		return false
	var source = slots(source_name)
	var target = slots(target_name)
	if source_index < 0 or source_index >= source.size() or target_index < 0 or target_index >= target.size():
		return false
	if source_name == target_name and source_index == target_index:
		return false
	var entry = source[source_index]
	if entry == null:
		return false
	var destination = target[target_index]
	if destination is Dictionary and destination.item == entry.item:
		destination.count += entry.count
		source[source_index] = null
	else:
		target[target_index] = entry
		source[source_index] = destination
	return true

func restore(data: Dictionary) -> bool:
	if not data.get("hotbar") is Array or not data.get("pocket") is Array or data.hotbar.size() != HOTBAR_SIZE or data.pocket.size() != POCKET_SIZE:
		return false
	for collection in [data.hotbar, data.pocket]:
		for entry in collection:
			if entry != null and (not entry is Dictionary or not entry.has_all(["item", "count"]) or not entry.item is String or not (entry.count is int or entry.count is float) or entry.count <= 0):
				return false
	hotbar = data.hotbar.duplicate(true)
	pocket = data.pocket.duplicate(true)
	return true
