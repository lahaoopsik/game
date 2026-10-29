extends Node2D
const Layout = preload("res://scripts/valley_layout.gd")
const Art = preload("res://scripts/art.gd")

func _draw() -> void:
	var grass_source = preload("res://assets/art/grass-clumps-v1.png")
	var crop_source = Rect2(grass_source.get_width() * 0.5, grass_source.get_height() * 0.60, grass_source.get_width() * 0.25, grass_source.get_height() * 0.40)
	var crop = Art.pixel_texture(grass_source, crop_source, Vector2i(12, 10))
	for field in Layout.VILLAGE_FIELDS:
		draw_rect(field.grow(4), Color("927143"))
		draw_rect(field, Color("9d6d3d"))
		for row in range(int(field.size.y / 24)):
			var start = field.position + Vector2(0, row * 24)
			draw_line(start + Vector2(0, 20), start + Vector2(field.size.x, 20), Color("714f32"), 3)
			for column in range(int(field.size.x / 32)):
				var p = start + Vector2(column * 32 + 5, 0)
				draw_texture_rect(crop, Rect2(p, Vector2(24, 20)), false)
	for p in Layout.ROCKS:
		draw_rock(p, 1.0)
		draw_rock(p + Vector2(22, 11), 0.5)
	for p in Layout.BUSHES:
		Art.draw_asset(self, 2, 0, p - Vector2(30, 50), Vector2(60, 60))
	for i in range(Layout.FLOWER_BEDS.size()):
		var p: Vector2 = Layout.FLOWER_BEDS[i]
		Art.draw_variant(self, i % 2, 1, p - Vector2(30, 30), Vector2(60, 42))
	for p in [Vector2(925, 710), Vector2(1355, 610), Vector2(1660, 1380), Vector2(1900, 1190)]:
		Art.draw_variant(self, 2, 1, p - Vector2(27, 30), Vector2(54, 40))
	var magical_props = [Vector2(855, 790), Vector2(1400, 680), Vector2(1590, 1170), Vector2(1710, 1420)]
	for i in range(magical_props.size()):
		Art.draw_fantasy(self, i, 1, magical_props[i] - Vector2(30, 40), Vector2(60, 48))
	for y in [220, 410, 670, 780, 1190, 1370, 1580]:
		var p = Vector2(Layout.river_x(y) + 68, y)
		for i in range(5):
			draw_line(p + Vector2(i * 4, 0), p + Vector2(i * 5 - 5, -21 - i % 3 * 6), Color("627e4a"), 2)
			if i % 2 == 0:
				draw_rect(Rect2(p + Vector2(i * 5 - 7, -25 - i % 3 * 6), Vector2(4, 8)), Color("956b48"))

func draw_rock(p: Vector2, size: float) -> void:
	draw_set_transform(p, 0, Vector2.ONE * size)
	draw_colored_polygon(PackedVector2Array([Vector2(-16, 5), Vector2(-19, -5), Vector2(-10, -18), Vector2(9, -20), Vector2(21, -7), Vector2(17, 8)]), Color("7d8f80"))
	draw_colored_polygon(PackedVector2Array([Vector2(-17, -5), Vector2(-8, -16), Vector2(8, -17), Vector2(15, -7), Vector2(0, -4)]), Color("b4bca2"))
	draw_line(Vector2(-14, 5), Vector2(16, 8), Color("64764f"), 4)
	draw_set_transform(Vector2.ZERO)
