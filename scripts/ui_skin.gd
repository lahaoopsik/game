extends RefCounted
static var frame_texture: Texture2D

static func panel_style() -> StyleBoxTexture:
	if frame_texture==null:
		frame_texture=preload("res://assets/art/native/ui-panel.png")
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

static func slot_style(selected: bool=false) -> StyleBoxTexture:
	var style=StyleBoxTexture.new()
	style.texture=load("res://assets/art/native/ui-slot-%d.png" % int(selected))
	style.texture_margin_left=4
	style.texture_margin_right=4
	style.texture_margin_top=4
	style.texture_margin_bottom=4
	return style
