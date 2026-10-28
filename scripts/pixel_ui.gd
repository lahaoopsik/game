extends CanvasLayer
signal inventory_toggled(opened: bool)
const FONT = preload("res://assets/fonts/PressStart2P-Regular.ttf")
var resources: Label
var inventory_count: Label
var message: Label
var help_panel: PanelContainer
var inventory_panel: PanelContainer
var message_age = 0.0
var previous_message = ""

class WoodIcon extends Control:
	func _draw() -> void:
		for i in range(3):
			var p = Vector2(6 + i % 2 * 11, 8 + i * 6)
			draw_rect(Rect2(p, Vector2(18, 7)), Color("704832"))
			draw_rect(Rect2(p + Vector2(0, 1), Vector2(14, 3)), Color("af7a48"))
			draw_rect(Rect2(p + Vector2(14, 0), Vector2(6, 6)), Color("e4bd7b"))
			draw_rect(Rect2(p + Vector2(16, 2), Vector2(2, 2)), Color("987047"))

func _ready() -> void:
	var vitals = panel(Vector2(20, 20), Vector2(260, 76))
	var vital_rows = VBoxContainer.new()
	vital_rows.add_theme_constant_override("separation", 12)
	vitals.add_child(vital_rows)
	var hp = label("ЗДОРОВЬЕ  —", 12)
	hp.add_theme_color_override("font_color", Color("f0b6a7"))
	hp.tooltip_text = "Система здоровья ещё не реализована"
	vital_rows.add_child(hp)
	var energy = label("ЭНЕРГИЯ  — / —", 12)
	energy.add_theme_color_override("font_color", Color("b5e7dd"))
	energy.tooltip_text = "Энергия — вместимость связей; система появится со спутником"
	vital_rows.add_child(energy)
	var companion_panel = panel(Vector2(300, 20), Vector2(215, 50))
	companion_panel.add_child(label("СПУТНИК\nНЕТ", 10))
	var bar = panel(Vector2(350, 710), Vector2(580, 68))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	bar.add_child(row)
	for i in range(9):
		var slot = make_slot(i, true)
		row.add_child(slot)
	message = label("Добудь дерево и построй верстак", 10)
	message.position = Vector2(180, 655)
	message.size = Vector2(920, 25)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_color_override("font_shadow_color", Color("203a34"))
	message.add_theme_constant_override("shadow_offset_x", 2)
	message.add_theme_constant_override("shadow_offset_y", 2)
	add_child(message)
	var hint = label("TAB ИНВЕНТАРЬ   B СТРОИТЬ   F1 ПОМОЩЬ", 8)
	hint.position = Vector2(430, 690)
	add_child(hint)
	help_panel = panel(Vector2(285, 170), Vector2(710, 430))
	var instructions = label("УПРАВЛЕНИЕ\n\nWASD / СТРЕЛКИ — ИДТИ\nSHIFT — БЫСТРЕЕ\nЛКМ ПО СТВОЛУ — ПРИЗВАТЬ ТОПОР\nB, ЗАТЕМ ЛКМ — ЧЕРТЁЖ\nE У ЧЕРТЕЖА — МАТЕРИАЛЫ / РАБОТА\nESC / ПКМ — ОТМЕНА\nTAB — ИНВЕНТАРЬ\nF5 / F9 — СОХРАНИТЬ / ЗАГРУЗИТЬ\nF6 — СЛЕДУЮЩАЯ ЧАСТЬ СУТОК\n\nF1 — ЗАКРЫТЬ", 12)
	instructions.add_theme_constant_override("line_spacing", 12)
	help_panel.add_child(instructions)
	help_panel.hide()
	inventory_panel = panel(Vector2(330, 195), Vector2(620, 410))
	inventory_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var inventory = VBoxContainer.new()
	inventory.add_theme_constant_override("separation", 20)
	inventory_panel.add_child(inventory)
	inventory.add_child(label("ИНВЕНТАРЬ", 16))
	var grid = GridContainer.new()
	grid.columns = 9
	grid.add_theme_constant_override("h_separation", 7)
	grid.add_theme_constant_override("v_separation", 7)
	inventory.add_child(grid)
	for i in range(27):
		grid.add_child(make_slot(i, false))
	inventory.add_child(label("TAB / ESC — ЗАКРЫТЬ", 10))
	inventory_panel.hide()

func make_slot(index: int, hotbar: bool) -> Panel:
	var slot = Panel.new()
	slot.custom_minimum_size = Vector2(54, 48)
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color("243a32")
	style.border_color = Color("8b9467")
	style.set_border_width_all(2)
	slot.add_theme_stylebox_override("panel", style)
	if hotbar:
		var number = label(str(index + 1), 8)
		number.position = Vector2(4, 4)
		number.modulate = Color("a8b58c")
		slot.add_child(number)
	if index == 0:
		var icon = WoodIcon.new()
		icon.position = Vector2(5, 4)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(icon)
		var count = label("0", 8)
		count.position = Vector2(35, 34)
		slot.add_child(count)
		if hotbar:
			resources = count
		else:
			inventory_count = count
	return slot

func label(text: String, font_size: int) -> Label:
	var result = Label.new()
	result.text = text
	result.add_theme_font_override("font", FONT)
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", Color("fff1ca"))
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result

func panel(position: Vector2, size: Vector2) -> PanelContainer:
	var result = PanelContainer.new()
	result.position = position
	result.custom_minimum_size = size
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color("294b41")
	style.border_color = Color("c7bd86")
	style.set_border_width_all(2)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.shadow_color = Color(0.08, 0.16, 0.12, 0.5)
	style.shadow_offset = Vector2(3, 3)
	result.add_theme_stylebox_override("panel", style)
	add_child(result)
	return result

func set_inventory_open(opened: bool) -> void:
	inventory_panel.visible = opened
	help_panel.hide()
	inventory_toggled.emit(opened)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_TAB:
			set_inventory_open(not inventory_panel.visible)
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_ESCAPE and inventory_panel.visible:
			set_inventory_open(false)
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_F1:
			help_panel.visible = not help_panel.visible
			get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	inventory_count.text = resources.text
	if message.text != previous_message:
		previous_message = message.text
		message_age = 0
	message_age += delta
	message.modulate.a = clampf(5.0 - message_age, 0, 1)