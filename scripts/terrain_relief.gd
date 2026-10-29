extends Node2D
var terrain: RefCounted
var edges: Array = []
var time = 0.0

func _ready() -> void:
	# Exposed front faces give the fixed elevation a readable RPG silhouette.
	for y in range(terrain.SIZE.y - 1):
		for x in range(terrain.SIZE.x):
			var current = terrain.elevation_at(Vector2i(x, y))
			var lower = terrain.elevation_at(Vector2i(x, y + 1))
			if current > lower:
				edges.append({"x": x * 48, "y": (y + 1) * 48, "height": (current - lower) * 12, "ramp": terrain.is_ramp(Vector2(x * 48 + 24, (y + 1) * 48)), "water": terrain.material_at(Vector2i(x, y)) == terrain.Kind.WATER})

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	for edge in edges:
		var p = Vector2(edge.x, edge.y)
		if edge.water:
			draw_rect(Rect2(p, Vector2(48, edge.height + 8)), Color("80cfdc"))
			for i in range(6):
				var start = int(time * 10 + i * 3) % 8
				draw_line(p + Vector2(i * 8, start), p + Vector2(i * 8, edge.height), Color("d4f1e2"), 2)
			draw_line(p + Vector2(0, edge.height + 8), p + Vector2(48, edge.height + 8), Color("e5f3dd"), 4)
			continue
		if edge.ramp:
			for step in range(4):
				draw_rect(Rect2(p + Vector2(0, step * 4), Vector2(48, 2)), Color("c4b17c"))
			continue
		draw_rect(Rect2(p, Vector2(48, edge.height)), Color("a28152"))
		draw_rect(Rect2(p, Vector2(48, 3)), Color("d6bd79"))
		draw_rect(Rect2(p + Vector2(0, edge.height - 3), Vector2(48, 3)), Color("786749"))
		for i in range(3):
			draw_line(p + Vector2(4 + i * 16, 4), p + Vector2(14 + i * 16, 5), Color("c09c60"), 2)
