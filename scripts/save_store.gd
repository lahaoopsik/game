extends RefCounted
static var PATH: String = ProjectSettings.globalize_path("res://").trim_suffix("/").get_base_dir().path_join("saves/valley.json")

static func save_game(data: Dictionary) -> Error:
	var directory_error = DirAccess.make_dir_recursive_absolute(PATH.get_base_dir())
	if directory_error != OK:
		return directory_error
	var file = FileAccess.open(PATH + ".tmp", FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data))
	file.close()
	return DirAccess.rename_absolute(PATH + ".tmp", PATH)

static func load_game() -> Dictionary:
	if not FileAccess.file_exists(PATH):
		return {}
	var file = FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		return {}
	var data = JSON.parse_string(file.get_as_text())
	return data if data is Dictionary else {}
