extends RefCounted
const Layout = preload("res://scripts/valley_layout.gd")
const CELL = 48
const SIZE = Vector2i(50, 38)
enum Kind { GRASS, SAND, GRAVEL, DIRT, SOIL, ROCK, CLAY, WATER }
var overrides: Dictionary = {}
var base: Dictionary = {}

func _init() -> void:
	for y in range(SIZE.y):
		for x in range(SIZE.x):
			base[Vector2i(x, y)] = authored_material(Vector2(x * CELL + 24, y * CELL + 24))

func authored_material(p: Vector2) -> int:
	var river_distance = absf(p.x - Layout.river_x(p.y))
	if river_distance < 47:
		return Kind.WATER
	if river_distance < 78:
		return Kind.SAND
	if river_distance < 102:
		return Kind.GRAVEL
	for route in Layout.PATHS:
		for i in range(route.size() - 1):
			if p.distance_to(Geometry2D.get_closest_point_to_segment(p, route[i], route[i + 1])) < 30:
				return Kind.DIRT
	if in_patch(p, Vector2(1570, 520), Vector2(170, 130)) or in_patch(p, Vector2(1100, 1400), Vector2(180, 100)):
		return Kind.SOIL
	if in_patch(p, Vector2(1560, 1160), Vector2(110, 70)) or in_patch(p, Vector2(2090, 1210), Vector2(150, 100)):
		return Kind.ROCK
	if in_patch(p, Vector2(1710, 1100), Vector2(80, 100)):
		return Kind.GRAVEL
	if in_patch(p, Vector2(1350, 1250), Vector2(90, 75)):
		return Kind.CLAY
	return Kind.GRASS

func in_patch(p: Vector2, center: Vector2, radius: Vector2) -> bool:
	return ((p - center) / radius).length_squared() < 1.0

func key(cell: Vector2i) -> String:
	return "%d:%d" % [cell.x, cell.y]

func material_at(cell: Vector2i) -> int:
	return int(overrides.get(key(cell), {}).get("material", base.get(cell, Kind.GRASS)))

func elevation_at(cell: Vector2i) -> int:
	return authored_elevation(Vector2(cell * CELL) + Vector2.ONE * 24)

func authored_elevation(p: Vector2) -> int:
	if in_patch(p, Vector2(2020, 1200), Vector2(160, 120)):
		return 2
	if in_patch(p, Vector2(1950, 1260), Vector2(310, 260)) or in_patch(p, Vector2(1510, 430), Vector2(280, 170)):
		return 1
	return 0

func set_cell(cell: Vector2i, kind: int) -> bool:
	if cell.x < 0 or cell.y < 0 or cell.x >= SIZE.x or cell.y >= SIZE.y or kind < Kind.GRASS or kind > Kind.WATER:
		return false
	overrides[key(cell)] = {"material": kind}
	return true

func snapshot() -> Dictionary:
	return overrides.duplicate(true)

func restore(data: Dictionary) -> void:
	overrides.clear()
	for address in data:
		var coords = str(address).split(":")
		var value = data[address]
		if coords.size() == 2 and coords[0].is_valid_int() and coords[1].is_valid_int() and value is Dictionary:
			set_cell(Vector2i(int(coords[0]), int(coords[1])), int(value.get("material", -1)))

func control_image() -> Image:
	var image = Image.create(SIZE.x, SIZE.y, false, Image.FORMAT_RG8)
	for y in range(SIZE.y):
		for x in range(SIZE.x):
			image.set_pixel(x, y, Color(material_at(Vector2i(x, y)) / 255.0, (elevation_at(Vector2i(x, y)) + 4) / 255.0, 0))
	return image
