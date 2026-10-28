extends Node
## Visual time only; no changes to residents, growth or resource rules.
const CYCLE_SECONDS = 720.0
var phase = 0.32
var tint: CanvasModulate
var clock: Label

func _ready() -> void:
	tint = CanvasModulate.new()
	add_child(tint)
	var ui = CanvasLayer.new()
	add_child(ui)
	var panel = PanelContainer.new()
	panel.position = Vector2(1040, 20)
	panel.custom_minimum_size = Vector2(200, 60)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color("294b41")
	style.border_color = Color("c7bd86")
	style.set_border_width_all(2)
	style.content_margin_left = 14
	style.content_margin_top = 10
	panel.add_theme_stylebox_override("panel", style)
	ui.add_child(panel)
	clock = Label.new()
	clock.add_theme_font_override("font", preload("res://assets/fonts/PressStart2P-Regular.ttf"))
	clock.add_theme_font_size_override("font_size", 12)
	clock.add_theme_color_override("font_color", Color("fff0c2"))
	clock.add_theme_color_override("font_shadow_color", Color("243e38"))
	clock.add_theme_constant_override("shadow_offset_x", 2)
	clock.add_theme_constant_override("shadow_offset_y", 2)
	panel.add_child(clock)
	update_light()

func _process(delta: float) -> void:
	phase = fposmod(phase + delta / CYCLE_SECONDS, 1.0)
	update_light()

func advance_quarter_day() -> void:
	phase = fposmod(phase + 0.25, 1.0)
	update_light()

func update_light() -> void:
	var stops = [0.0, 0.20, 0.27, 0.34, 0.65, 0.75, 0.83, 1.0]
	var colors = [Color("444c7c"), Color("444c7c"), Color("d6a799"), Color("ffffff"), Color("ffffff"), Color("e5b08a"), Color("444c7c"), Color("444c7c")]
	for i in range(stops.size() - 1):
		if phase >= stops[i] and phase <= stops[i + 1]:
			tint.color = colors[i].lerp(colors[i + 1], smoothstep(stops[i], stops[i + 1], phase))
			break
	var minutes = int(phase * 1440)
	var period = "НОЧЬ" if phase < 0.22 or phase >= 0.83 else ("УТРО" if phase < 0.36 else ("ДЕНЬ" if phase < 0.70 else "ВЕЧЕР"))
	clock.text = "%s\n%02d:%02d" % [period, minutes / 60, minutes % 60]

func snapshot() -> Dictionary:
	return {"phase": phase}

func restore(data: Dictionary) -> void:
	phase = fposmod(float(data.get("phase", 0.32)), 1.0)
	update_light()
