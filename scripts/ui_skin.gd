extends RefCounted
static var frame_texture: Texture2D

static func panel_style() -> StyleBoxTexture:
	if frame_texture == null:
		var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
		for y in range(32):
			for x in range(32):
				var edge = mini(mini(x, 31 - x), mini(y, 31 - y))
				var color = Color("f3ce8d")
				if edge == 0:
					color = Color("56351f")
				elif edge == 1:
					color = Color("e6ae58") if x + y < 32 else Color("784523")
				elif edge < 5:
					color = Color("ab642f") if y > x else Color("c68640")
				elif edge == 5:
					color = Color("744020")
				elif edge == 6:
					color = Color("ffe5ad")
				image.set_pixel(x, y, color)
		for p in [Vector2i(3, 3), Vector2i(27, 3), Vector2i(3, 27), Vector2i(27, 27)]:
			image.fill_rect(Rect2i(p, Vector2i(2, 2)), Color("f9da89"))
		frame_texture = ImageTexture.create_from_image(image)
	var style = StyleBoxTexture.new()
	style.texture = frame_texture
	style.texture_margin_left = 8
	style.texture_margin_right = 8
	style.texture_margin_top = 8
	style.texture_margin_bottom = 8
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

static func slot_style(selected: bool = false) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color("edc480") if selected else Color("d8ac6c")
	style.border_color = Color("b34e2b") if selected else Color("a46a36")
	style.set_border_width_all(3 if selected else 2)
	style.shadow_color = Color("f9df9e")
	style.shadow_offset = Vector2(1, 1)
	return style
