extends RefCounted
## Authoritative game state. UI submits intent; only this object changes resources.
const WORLD_SIZE = Vector2(2400, 1800)
const GRID = 48
const COST = 12 # Temporary prototype balance, not a final game rule.
const REACH = 110.0
var wood: int = 0
var trees: Array = []
var buildings: Array = []
var next_id: int = 100

func _init() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = 8042
	for i in range(65):
		var p = Vector2(rng.randf_range(110, 2290), rng.randf_range(120, 1650))
		if p.distance_to(Vector2(1200, 900)) < 160 or absf(p.x - river_x(p.y)) < 95:
			continue
		trees.append({"id": i, "x": p.x, "y": p.y, "hp": 3})

static func river_x(y: float) -> float:
	return 390 + sin(y / 240.0) * 100

func can_place(p: Vector2) -> bool:
	if p.x < 72 or p.y < 72 or p.x > WORLD_SIZE.x - 72 or p.y > WORLD_SIZE.y - 72:
		return false
	if absf(p.x - river_x(p.y)) < 105:
		return false
	for t in trees:
		if Vector2(t.x, t.y).distance_to(p) < 65:
			return false
	for b in buildings:
		if Vector2(b.x, b.y).distance_to(p) < 96:
			return false
	return true

func command(action: String, actor: Vector2, target: Vector2) -> String:
	if action == "place":
		var p = (target / GRID).floor() * GRID + Vector2.ONE * GRID / 2
		if actor.distance_to(p) > 210:
			return "Чертёж слишком далеко"
		if not can_place(p) or actor.distance_to(p) < 60:
			return "Здесь нельзя разместить чертёж"
		buildings.append({"id": next_id, "x": p.x, "y": p.y, "wood": 0, "work": 0})
		next_id += 1
		return "Чертёж верстака размещён"
	if action == "chop":
		for i in range(trees.size()):
			var t: Dictionary = trees[i]
			var p = Vector2(t.x, t.y)
			if target.distance_to(p) < 65 and actor.distance_to(p) <= REACH:
				t.hp -= 1
				if t.hp <= 0:
					trees.remove_at(i)
					wood += 5
					return "+5 древесины"
				return "Удар топориком · осталось %d" % t.hp
		return "Подойди к дереву и нажми на его ствол"
	if action == "interact":
		for b in buildings:
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
	return {"version": 1, "wood": wood, "trees": trees.duplicate(true), "buildings": buildings.duplicate(true), "next_id": next_id, "player": [player_position.x, player_position.y]}

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
	wood = maxi(0, int(data.get("wood", 0)))
	trees = data.trees.duplicate(true)
	buildings = data.buildings.duplicate(true)
	next_id = int(data.get("next_id", 100))
	return true
