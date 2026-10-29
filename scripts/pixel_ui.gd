extends CanvasLayer
signal inventory_toggled(opened: bool)
signal save_requested
signal load_requested
signal quit_requested
const FONT = preload("res://assets/fonts/PressStart2P-Regular.ttf")
const INITIAL_SLOTS = 9
const PixelSkin = preload("res://scripts/ui_skin.gd")
var selected_slot = 0
var hotbar_slots: Array = []
var clock_label: Label
var inventory_model: RefCounted
var slot_views: Array = []
var map_panel: PanelContainer
var map_view: Control
var menu_panel: PanelContainer
var world_state: RefCounted
var player_position = Vector2.ZERO
var action_hint: Label
var time_phase = 0.3
var day_glyph: Control

class DayGlyph extends Control:
	var night = false
	func _draw() -> void:
		if night:
			draw_rect(Rect2(4,3,10,16),Color("7799bb"))
			draw_rect(Rect2(1,6,16,10),Color("a8c5cc"))
			draw_rect(Rect2(9,2,10,12),Color("f3ce8d"))
		else:
			draw_rect(Rect2(5,5,12,12),Color("e2a83b"))
			draw_rect(Rect2(7,7,8,8),Color("fff0aa"))
			for p in [Vector2(9,0),Vector2(9,20),Vector2(0,9),Vector2(20,9)]:
				draw_rect(Rect2(p,Vector2(3,3)),Color("bf8634"))
var resources: Label
var inventory_count: Label
var message: Label
var help_panel: PanelContainer
var inventory_panel: PanelContainer
var message_age = 0.0
var previous_message = ""

class WoodIcon extends Control:
	var item_id = "wood"
	func _draw() -> void:
		var prop = preload("res://scripts/decor_catalog.gd").parse(item_id)
		if not prop.is_empty():
			var texture = preload("res://scripts/art.gd").prop_texture(prop.family,prop.variant)
			var size = Vector2(texture.get_size())
			size *= 32.0 / maxf(size.x,size.y)
			draw_texture_rect(texture,Rect2(Vector2(20,18)-size/2,size),false)
			return
		if item_id != "wood":
			return
		for i in range(3):
			var p = Vector2(6 + i % 2 * 11, 8 + i * 6)
			draw_rect(Rect2(p, Vector2(18, 7)), Color("704832"))
			draw_rect(Rect2(p + Vector2(0, 1), Vector2(14, 3)), Color("af7a48"))
			draw_rect(Rect2(p + Vector2(14, 0), Vector2(6, 6)), Color("e4bd7b"))
			draw_rect(Rect2(p + Vector2(16, 2), Vector2(2, 2)), Color("987047"))

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var vitals = panel(Vector2(1000, 20), Vector2(260, 154))
	var vital_rows = VBoxContainer.new()
	vital_rows.add_theme_constant_override("separation", 12)
	vitals.add_child(vital_rows)
	clock_label = label("ДЕНЬ 1   07:40", 12)
	vital_rows.add_child(clock_label)
	day_glyph=DayGlyph.new()
	day_glyph.position=Vector2(1214,34)
	day_glyph.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(day_glyph)
	var hp = label("ЗДОРОВЬЕ  —", 10)
	hp.add_theme_color_override("font_color", Color("9c4436"))
	hp.tooltip_text = "Система здоровья ещё не реализована"
	vital_rows.add_child(hp)
	var energy = label("ЭНЕРГИЯ  — / —", 10)
	energy.add_theme_color_override("font_color", Color("356a70"))
	energy.tooltip_text = "Энергия — вместимость связей; система появится со спутником"
	vital_rows.add_child(energy)
	vital_rows.add_child(label("СПУТНИК: НЕТ", 10))
	var bar = panel(Vector2(350, 710), Vector2(580, 68))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	bar.add_child(row)
	for i in range(INITIAL_SLOTS):
		var slot = make_slot(i, true)
		row.add_child(slot)
		hotbar_slots.append(slot)
	message = label("Добудь дерево и построй верстак", 10)
	message.position = Vector2(180, 655)
	message.size = Vector2(920, 25)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_color_override("font_color", Color("fff1ca"))
	message.add_theme_color_override("font_shadow_color", Color("203a34"))
	message.add_theme_constant_override("shadow_offset_x", 2)
	message.add_theme_constant_override("shadow_offset_y", 2)
	add_child(message)
	var hint = label("TAB ИНВЕНТАРЬ   B СТРОИТЬ   F1 ПОМОЩЬ", 8)
	action_hint=hint
	hint.position = Vector2(430, 690)
	hint.add_theme_color_override("font_color", Color("fff1ca"))
	add_child(hint)
	help_panel = panel(Vector2(285, 170), Vector2(710, 430))
	var instructions = label("УПРАВЛЕНИЕ\n\nWASD / СТРЕЛКИ — ИДТИ\nSHIFT — БЫСТРЕЕ\nЛКМ ПО СТВОЛУ — ПРИЗВАТЬ ТОПОР\nB, ЗАТЕМ ЛКМ — ЧЕРТЁЖ\nE У ЧЕРТЕЖА — МАТЕРИАЛЫ / РАБОТА\nESC / ПКМ — ОТМЕНА\nTAB — ИНВЕНТАРЬ\nF5 / F9 — СОХРАНИТЬ / ЗАГРУЗИТЬ\nF6 — СЛЕДУЮЩАЯ ЧАСТЬ СУТОК\n\nF1 — ЗАКРЫТЬ", 12)
	instructions.add_theme_constant_override("line_spacing", 12)
	help_panel.add_child(instructions)
	help_panel.hide()
	inventory_panel = panel(Vector2(484, 268), Vector2(312, 252))
	inventory_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var inventory = VBoxContainer.new()
	inventory.add_theme_constant_override("separation", 20)
	inventory_panel.add_child(inventory)
	inventory.add_child(label("ИНВЕНТАРЬ", 16))
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 7)
	grid.add_theme_constant_override("v_separation", 7)
	inventory.add_child(grid)
	for i in range(6):
		grid.add_child(make_slot(i, false))
	inventory.add_child(label("TAB / ESC — ЗАКРЫТЬ", 10))
	inventory_panel.hide()
	map_panel = panel(Vector2(212,80),Vector2(856,642))
	map_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var map_box = VBoxContainer.new()
	map_panel.add_child(map_box)
	map_box.add_child(label("СОЛНЕЧНАЯ ДОЛИНА",16))
	map_view = preload("res://scripts/map_view.gd").new()
	map_box.add_child(map_view)
	map_box.add_child(label("M / ESC — ЗАКРЫТЬ",10))
	map_panel.hide()
	menu_panel = panel(Vector2(475,210),Vector2(330,370))
	menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var menu = VBoxContainer.new()
	menu.add_theme_constant_override("separation",18)
	menu_panel.add_child(menu)
	menu.add_child(label("ПАУЗА",16))
	for entry in [["ПРОДОЛЖИТЬ",0],["СОХРАНИТЬ",1],["ЗАГРУЗИТЬ",2],["ВЫЙТИ",3]]:
		var button = Button.new()
		button.text = entry[0]
		button.custom_minimum_size = Vector2(270,42)
		button.add_theme_font_override("font",FONT)
		button.add_theme_font_size_override("font_size",12)
		button.add_theme_color_override("font_color",Color("58331e"))
		button.add_theme_color_override("font_hover_color",Color("58331e"))
		button.add_theme_color_override("font_pressed_color",Color("58331e"))
		button.add_theme_stylebox_override("normal",PixelSkin.slot_style())
		button.add_theme_stylebox_override("hover",PixelSkin.slot_style(true))
		var action: int = entry[1]
		button.pressed.connect(func(): menu_action(action))
		menu.add_child(button)
	menu_panel.hide()

func make_slot(index: int, hotbar: bool) -> Panel:
	var slot = preload("res://scripts/inventory_slot.gd").new()
	slot.container = "hotbar" if hotbar else "pocket"
	slot.index = index
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	slot_views.append(slot)
	slot.custom_minimum_size = Vector2(54, 48)
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_theme_stylebox_override("panel", PixelSkin.slot_style(hotbar and index == selected_slot))
	if hotbar:
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		slot.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				select_slot(index)
		)
	if hotbar:
		var number = label(str(index + 1), 8)
		number.position = Vector2(4, 4)
		number.modulate = Color("80542f")
		slot.add_child(number)
	var icon = WoodIcon.new()
	icon.name = "Icon"
	icon.position = Vector2(5, 4)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(icon)
	var count = label("", 8)
	count.name = "Count"
	count.position = Vector2(30, 34)
	slot.add_child(count)
	var item_name = label("", 9)
	item_name.name = "ItemName"
	item_name.position = Vector2(17, 18)
	slot.add_child(item_name)
	if index == 0:
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
	result.add_theme_color_override("font_color", Color("58331e"))
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result

func panel(position: Vector2, size: Vector2) -> PanelContainer:
	var result = PanelContainer.new()
	result.position = position
	result.custom_minimum_size = size
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result.add_theme_stylebox_override("panel", PixelSkin.panel_style())
	add_child(result)
	return result

func select_slot(index: int) -> void:
	selected_slot = clampi(index, -1, INITIAL_SLOTS - 1)
	for i in range(hotbar_slots.size()):
		hotbar_slots[i].add_theme_stylebox_override("panel", PixelSkin.slot_style(i == selected_slot))

func set_inventory_open(opened: bool) -> void:
	inventory_panel.visible = opened
	help_panel.hide()
	inventory_toggled.emit(opened)

func is_modal_open() -> bool:
	return inventory_panel.visible or map_panel.visible or menu_panel.visible

func set_map_open(opened: bool) -> void:
	map_panel.visible = opened
	inventory_panel.hide()
	help_panel.hide()
	if opened and world_state != null:
		map_view.refresh(world_state)
	inventory_toggled.emit(is_modal_open())

func set_menu_open(opened: bool) -> void:
	menu_panel.visible = opened
	get_tree().paused = opened
	inventory_toggled.emit(is_modal_open())

func menu_action(action: int) -> void:
	match action:
		0: set_menu_open(false)
		1: save_requested.emit()
		2: load_requested.emit()
		3: set_menu_open(false); quit_requested.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_9:
			select_slot(event.physical_keycode - KEY_1)
			get_viewport().set_input_as_handled()
		if event.physical_keycode == KEY_TAB:
			if menu_panel.visible:
				return
			map_panel.hide()
			set_inventory_open(not inventory_panel.visible)
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_M:
			if not menu_panel.visible:
				set_map_open(not map_panel.visible)
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_ESCAPE:
			if inventory_panel.visible: set_inventory_open(false)
			elif map_panel.visible: set_map_open(false)
			elif help_panel.visible: help_panel.hide()
			else: set_menu_open(not menu_panel.visible)
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_F1:
			help_panel.visible = not help_panel.visible
			get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if day_glyph!=null:
		day_glyph.night=time_phase<0.22 or time_phase>0.83
		day_glyph.queue_redraw()
	if map_view != null:
		map_view.player_position = player_position
	if inventory_model != null:
		for view in slot_views:
			view.inventory = inventory_model
			view.dragging_enabled = inventory_panel.visible
			view.mouse_filter = Control.MOUSE_FILTER_STOP
			var entry = inventory_model.slots(view.container)[view.index]
			var icon = view.get_node("Icon")
			icon.visible = entry is Dictionary
			icon.item_id = str(entry.item) if entry is Dictionary else ""
			icon.queue_redraw()
			view.get_node("Count").text = str(entry.count) if entry is Dictionary else ""
			view.get_node("ItemName").text = str(entry.item).left(2).to_upper() if entry is Dictionary and entry.item != "wood" and not str(entry.item).begins_with("prop:") else ""
			view.tooltip_text = "%s: %d" % ["Древесина" if entry.item == "wood" else preload("res://scripts/decor_catalog.gd").display_name(entry.item), entry.count] if entry is Dictionary else "Пусто"
	if message.text != previous_message:
		previous_message = message.text
		message_age = 0
	message_age += delta
	message.modulate.a = clampf(5.0 - message_age, 0, 1)
