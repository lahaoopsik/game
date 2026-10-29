extends Camera2D
## Physics remains continuous; the camera renders on a stable two-pixel grid.
func _ready() -> void:
	top_level = true
	position_smoothing_enabled = false
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	update_camera()

func _physics_process(_delta: float) -> void:
	update_camera()

func update_camera() -> void:
	global_position = (get_parent().global_position / 2.0).round() * 2.0
