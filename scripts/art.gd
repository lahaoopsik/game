extends RefCounted
## One source atlas, uniform cell geometry, no filtering between pixels.
const ATLAS = preload("res://assets/art/valley-atlas-v1.png")
const GRASS = preload("res://assets/art/grass-v1.png")
const VARIANTS = preload("res://assets/art/scenery-variants-v1.png")
const FANTASY = preload("res://assets/art/fantasy-scenery-v2.png")
const CELL = 256.0
static var frames: Dictionary = {}

static func region(column: int, row: int) -> Rect2:
	var dimensions = Vector2(ATLAS.get_width(), ATLAS.get_height())
	if row == 0:
		var left = [0.0, 0.274, 0.535, 0.735][column]
		var right = [0.266, 0.526, 0.711, 0.984][column]
		return Rect2(Vector2(left * dimensions.x, 0), Vector2((right - left) * dimensions.x, 0.293 * dimensions.y))
	var top = [0.0, 0.296, 0.510, 0.731][row]
	var bottom = [0.293, 0.506, 0.725, 0.961][row]
	return Rect2(Vector2(column * dimensions.x / 4, top * dimensions.y), Vector2(dimensions.x / 4, (bottom - top) * dimensions.y))

static func frame(column: int, row: int) -> AtlasTexture:
	var key = row * 4 + column
	if frames.has(key):
		return frames[key]
	var texture = AtlasTexture.new()
	texture.atlas = ATLAS
	texture.region = region(column, row)
	frames[key] = texture
	return texture

static func draw_asset(canvas: CanvasItem, column: int, row: int, position: Vector2, size: Vector2, tint: Color = Color.WHITE) -> void:
	canvas.draw_texture_rect_region(ATLAS, Rect2(position, size), region(column, row), tint)

static func draw_variant(canvas: CanvasItem, column: int, row: int, position: Vector2, size: Vector2, tint: Color = Color.WHITE) -> void:
	var dimensions = Vector2(VARIANTS.get_width(), VARIANTS.get_height())
	var top = 0.0 if row == 0 else 0.66
	var height = 0.63 if row == 0 else 0.32
	var rect = Rect2(Vector2(column * dimensions.x / 4, dimensions.y * top), Vector2(dimensions.x / 4, dimensions.y * height))
	canvas.draw_texture_rect_region(VARIANTS, Rect2(position, size), rect, tint)

static func draw_fantasy(canvas: CanvasItem, column: int, row: int, position: Vector2, size: Vector2, tint: Color = Color.WHITE) -> void:
	var dimensions = Vector2(FANTASY.get_width(), FANTASY.get_height())
	var left = [0.0, 0.26, 0.467, 0.768][column] if row == 0 else column / 4.0
	var right = [0.259, 0.466, 0.767, 1.0][column] if row == 0 else (column + 1) / 4.0
	var rect = Rect2(Vector2(left * dimensions.x, 0 if row == 0 else dimensions.y * 0.69), Vector2((right - left) * dimensions.x, dimensions.y * (0.69 if row == 0 else 0.31)))
	canvas.draw_texture_rect_region(FANTASY, Rect2(position, size), rect, tint)
