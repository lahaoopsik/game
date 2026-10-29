extends RefCounted
## Authoritative game state. UI submits intent; only this object changes resources.
const WORLD_SIZE = preload("res://scripts/valley_layout.gd").WORLD_SIZE
const GRID = 48
const COST = 12 # Temporary prototype balance, not a final game rule.
const REACH = 110.0
const Layout = preload("res://scripts/valley_layout.gd")
const Terrain = preload("res://scripts/terrain_grid.gd")
var terrain = Terrain.new()
const Inventory = preload("res://scripts/inventory.gd")
const Decor = preload("res://scripts/decor_catalog.gd")
var inventory = Inventory.new()
var wood: int:
	get: return inventory.count("wood")
	set(value): inventory.set_count("wood", value)
var trees: Array = []
var buildings: Array = []
var next_id: int = 100
var grass: Array = []
var cleared_grass: Array = []
var decorations: Array = []
var next_decor_id = 1
var location = "outside"

func _init() -> void:
	for i in range(Layout.TREES.size()):
		var p: Vector2 = Layout.TREES[i]
		if Layout.is_village_reserved(p):
			continue
		trees.append({"id": i, "x": p.x, "y": p.y, "hp": 3})
	reset_grass()
	decorations = Layout.decorations()

func reset_grass() -> void:
	grass = Layout.grass_clumps().filter(func(clump): return clump.id not in cleared_grass and terrain.material_at(Vector2i(Vector2(clump.x, clump.y) / 48)) == Terrain.Kind.GRASS)

static func river_x(y: float) -> float:
	return Layout.river_x(y)

func can_place(p: Vector2) -> bool:
	if location=="chief_tent":
		return can_place_decor(p) and p.distance_to(Vector2(480,600))>80
	if p.x < 72 or p.y < 72 or p.x > WORLD_SIZE.x - 72 or p.y > WORLD_SIZE.y - 72:
		return false
	if Layout.is_bridge(p):
		return false
	if Layout.is_village_reserved(p):
		return false
	for prop in decorations:
		if prop.get("location","outside")==location and p.distance_to(Vector2(prop.x,prop.y))<55:
			return false
	if terrain.material_at(Vector2i((p / Terrain.CELL).floor())) == Terrain.Kind.WATER:
		return false
	for t in trees:
		if Vector2(t.x, t.y).distance_to(p) < 65:
			return false
	for b in buildings:
		if b.get("location","outside")!=location:
			continue
		if Vector2(b.x, b.y).distance_to(p) < 96:
			return false
	return true

func command(action: String, actor: Vector2, target: Vector2, payload: Dictionary = {}) -> String:
	if action == "place_decor":
		var item = str(payload.get("item", ""))
		var prop = Decor.parse(item)
		var p = (target / GRID).floor() * GRID + Vector2.ONE * GRID / 2
		if prop.is_empty() or inventory.count(item) < 1:
			return "Предмета нет в инвентаре"
		if actor.distance_to(p) > 180 or not can_place_decor(p):
			return "Здесь предмет не помещается"
		inventory.set_count(item, inventory.count(item) - 1)
		decorations.append({"id":"placed:%d" % next_decor_id,"family":prop.family,"variant":prop.variant,"x":p.x,"y":p.y,"rotation":int(payload.get("rotation",0)) % 4,"location":location})
		next_decor_id += 1
		return "Предмет установлен"
	if action == "place":
		var p = (target / GRID).floor() * GRID + Vector2.ONE * GRID / 2
		if actor.distance_to(p) > 210:
			return "Чертёж слишком далеко"
		if not can_place(p) or actor.distance_to(p) < 60:
			return "Здесь нельзя разместить чертёж"
		buildings.append({"id": next_id, "x": p.x, "y": p.y, "wood": 0, "work": 0, "rotation": int(payload.get("rotation",0)) % 4,"location":location})
		next_id += 1
		return "Чертёж верстака размещён"
	if action == "chop":
		for i in range(decorations.size()):
			var prop: Dictionary = decorations[i]
			if prop.get("location","outside")!=location:
				continue
			if Decor.portable(prop.family, int(prop.variant)) and target.distance_to(Vector2(prop.x, prop.y)) < 24 and actor.distance_to(Vector2(prop.x, prop.y)) <= REACH:
				var item = Decor.item_id(prop.family, int(prop.variant))
				if not inventory.add(item, 1):
					return "Нет места в инвентаре"
				decorations.remove_at(i)
				return "Разобрано: %s" % Decor.display_name(item)
		if location!="outside":
			return "Здесь нечего разбирать"
		for i in range(trees.size()):
			var t: Dictionary = trees[i]
			var p = Vector2(t.x, t.y)
			if target.distance_to(p) < 65 and actor.distance_to(p) <= REACH:
				t.hp -= 1
				if t.hp <= 0:
					if not inventory.add("wood", 5):
						t.hp = 1
						return "Нет места в инвентаре"
					trees.remove_at(i)
					return "+5 древесины"
				return "Удар топориком · осталось %d" % t.hp
		for i in range(grass.size()):
			var p = Vector2(grass[i].x, grass[i].y)
			if target.distance_to(p) < 24 and actor.distance_to(p) < REACH:
				cleared_grass.append(grass[i].id)
				grass.remove_at(i)
				return "Трава срезана"
		return "Подойди к дереву или высокой траве"
	if action == "interact":
		for b in buildings:
			if b.get("location","outside")!=location:
				continue
			var p = Vector2(b.x, b.y)
			if actor.distance_to(p) <= REACH and target.distance_to(p) < 70:
				if b.wood < COST:
					var amount = mini(wood, COST - int(b.wood))
					wood -= amount
					b.wood += amount
					return "Внесено дерева: %d/%d" % [b.wood, COST]
				if b.work < 4:
					b.work += 1
					return "Верстак построен!" if b.work == 4 else "Строительство: %d/4" % b.work
				return "Верстак готов · рецепты появятся позже"
		return "Подойди к чертежу и наведи на него мышь"
	return "Неизвестная команда"

func snapshot(player_position: Vector2) -> Dictionary:
	return {"version": 1, "layout": Layout.ID, "layout_revision": Layout.REVISION, "location":location, "terrain": terrain.snapshot(), "inventory": inventory.snapshot(), "decorations": decorations.duplicate(true), "next_decor_id": next_decor_id, "cleared_grass": cleared_grass.duplicate(), "wood": wood, "trees": trees.duplicate(true), "buildings": buildings.duplicate(true), "next_id": next_id, "player": [player_position.x, player_position.y]}

func restore(data: Dictionary) -> bool:
	if data.get("version") != 1 or not data.get("trees") is Array or not data.get("buildings") is Array:
		return false
	if not data.get("player") is Array or data.player.size() != 2:
		return false
	for collection in [data.trees, data.buildings]:
		for entry in collection:
			if not entry is Dictionary or not entry.has_all(["id", "x", "y"]):
				return false
	for t in data.trees:
		if not t.has("hp"):
			return false
	for b in data.buildings:
		if not b.has_all(["wood", "work"]):
			return false
	var loaded_inventory = Inventory.new()
	if data.has("inventory"):
		if not data.inventory is Dictionary or not loaded_inventory.restore(data.inventory):
			return false
	else:
		loaded_inventory.set_count("wood", maxi(0, int(data.get("wood", 0))))
	inventory = loaded_inventory
	location = str(data.get("location","outside"))
	if location not in ["outside","chief_tent"]:
		location="outside"
	decorations = data.get("decorations", Layout.decorations()).duplicate(true)
	next_decor_id = int(data.get("next_decor_id", 1))
	terrain.restore(data.get("terrain", {}))
	cleared_grass = data.get("cleared_grass", []).duplicate()
	reset_grass()
	if data.get("layout", "") == Layout.ID:
		trees = data.trees.duplicate(true)
		if int(data.get("layout_revision", 1)) < Layout.REVISION:
			for i in range(50, Layout.TREES.size()):
				var p: Vector2 = Layout.TREES[i]
				if Layout.is_village_reserved(p):
					continue
				trees.append({"id": i, "x": p.x, "y": p.y, "hp": 3})
	else:
		# Old prototype forest is replaced; inventory and buildings remain intact.
		trees = get_script().new().trees
		for b in data.buildings:
			trees = trees.filter(func(t): return Vector2(t.x, t.y).distance_to(Vector2(b.x, b.y)) > 90)
	buildings = data.buildings.duplicate(true)
	next_id = int(data.get("next_id", 100))
	return true

func can_place_decor(p: Vector2) -> bool:
	if location=="chief_tent":
		if ((p-Vector2(480,320))/Vector2(420,250)).length_squared()>1:
			return false
		for prop in decorations:
			if prop.get("location","outside")==location and p.distance_to(Vector2(prop.x,prop.y))<36:
				return false
		for building in buildings:
			if building.get("location","outside")==location and p.distance_to(Vector2(building.x,building.y))<65:
				return false
		return true
	if p.x < 25 or p.y < 25 or p.x > WORLD_SIZE.x - 25 or p.y > WORLD_SIZE.y - 25:
		return false
	if terrain.material_at(Vector2i((p / 48).floor())) == Terrain.Kind.WATER or Layout.is_bridge(p):
		return false
	for prop in Layout.VILLAGE:
		if prop.z < 4 and p.distance_to(Vector2(prop.x, prop.y - 30)) < (115 if prop.z == 0 else 75):
			return false
	for field in Layout.VILLAGE_FIELDS:
		if field.has_point(p):
			return false
	for prop in decorations:
		if prop.get("location","outside")!=location:
			continue
		if p.distance_to(Vector2(prop.x, prop.y)) < 36:
			return false
	for tree in trees:
		if p.distance_to(Vector2(tree.x, tree.y)) < 35:
			return false
	for building in buildings:
		if building.get("location","outside")!=location:
			continue
		if p.distance_to(Vector2(building.x, building.y)) < 65:
			return false
	return true
