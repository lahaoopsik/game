extends Panel
var inventory: RefCounted
var container = "hotbar"
var index = 0
var dragging_enabled = false

func _get_drag_data(_position: Vector2) -> Variant:
	if not dragging_enabled or inventory == null:
		return null
	var entry = inventory.slots(container)[index]
	if entry == null:
		return null
	var preview = Panel.new()
	preview.size = Vector2(54, 48)
	preview.modulate.a = 0.85
	preview.add_theme_stylebox_override("panel", preload("res://scripts/ui_skin.gd").slot_style(true))
	for child in get_children():
		if child.name in ["Icon", "Count", "ItemName"]:
			var duplicate = child.duplicate()
			if child.name == "Icon":
				duplicate.item_id = child.item_id
			preview.add_child(duplicate)
	set_drag_preview(preview)
	return {"model": inventory, "source": container, "index": index}

func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	return dragging_enabled and data is Dictionary and data.get("model") == inventory and data.has_all(["source", "index"])

func _drop_data(_position: Vector2, data: Variant) -> void:
	if _can_drop_data(_position, data):
		inventory.move(data.source, int(data.index), container, index)
