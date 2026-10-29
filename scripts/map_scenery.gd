extends Node2D
const Layout = preload("res://scripts/valley_layout.gd")
const Art = preload("res://scripts/art.gd")

func _draw() -> void:
	var crop=preload("res://assets/art/native/crop.png")
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
		Art.draw_native(self,Art.prop_texture("micro",12),p-Vector2(16,40),Vector2(32,56),Color.WHITE)

func draw_rock(p: Vector2,size: float) -> void:
	var texture=preload("res://assets/art/native/rock.png")
	var pixels=texture.get_size()*2
	draw_texture_rect(texture,Rect2(p-Vector2(pixels.x/2,pixels.y-6),pixels),false)
