extends RefCounted
## One source atlas, uniform cell geometry, no filtering between pixels.
const ATLAS = preload("res://assets/art/valley-atlas-v1.png")
const GRASS = preload("res://assets/art/grass-v1.png")
const VARIANTS = preload("res://assets/art/scenery-variants-v1.png")
const FANTASY = preload("res://assets/art/fantasy-scenery-v2.png")
const DEPTH = preload("res://assets/art/depth-scenery-v3.png")
const MICRO = preload("res://assets/art/micro-props-v1.png")
const CAMP = preload("res://assets/art/goblin-camp-v3.png")
const TORCH = preload("res://assets/art/torch-v1.png")
const CELL = 256.0
static var frames: Dictionary = {}
static var pixel_textures: Dictionary = {}
static var occluder_cache: Dictionary = {}

static func pixel_texture(texture: Texture2D, source: Rect2, target: Vector2i) -> Texture2D:
	var key = "%s:%s:%s" % [texture.get_instance_id(), source, target]
	if pixel_textures.has(key):
		return pixel_textures[key]
	var image = texture.get_image().get_region(Rect2i(source))
	image.resize(target.x, target.y, Image.INTERPOLATE_NEAREST)
	var result = ImageTexture.create_from_image(image)
	pixel_textures[key] = result
	return result

static func region(column: int, row: int) -> Rect2:
	var dimensions = Vector2(ATLAS.get_width(), ATLAS.get_height())
	if row == 0:
		var left = [0.0, 0.274, 0.535, 0.735][column]
		var right = [0.266, 0.526, 0.711, 0.984][column]
		return Rect2(Vector2(left * dimensions.x, 0), Vector2((right - left) * dimensions.x, 0.293 * dimensions.y))
	var top = [0.0, 0.296, 0.510, 0.731][row]
	var bottom = [0.293, 0.506, 0.725, 0.961][row]
	return Rect2(Vector2(column * dimensions.x / 4, top * dimensions.y), Vector2(dimensions.x / 4, (bottom - top) * dimensions.y))

static func frame(column: int, row: int) -> Texture2D:
	var key = row * 4 + column
	if frames.has(key):
		return frames[key]
	var texture = pixel_texture(ATLAS, region(column, row), Vector2i(48, 40))
	frames[key] = texture
	return texture

static func draw_asset(canvas: CanvasItem, column: int, row: int, position: Vector2, size: Vector2, tint: Color = Color.WHITE) -> void:
	var texture = pixel_texture(ATLAS, region(column, row), Vector2i(size / 2))
	canvas.draw_texture_rect(texture, Rect2(position.round(), size), false, tint)

static func draw_variant(canvas: CanvasItem, column: int, row: int, position: Vector2, size: Vector2, tint: Color = Color.WHITE) -> void:
	var dimensions = Vector2(VARIANTS.get_width(), VARIANTS.get_height())
	var top = 0.0 if row == 0 else 0.66
	var height = 0.63 if row == 0 else 0.32
	var rect = Rect2(Vector2(column * dimensions.x / 4, dimensions.y * top), Vector2(dimensions.x / 4, dimensions.y * height))
	canvas.draw_texture_rect(pixel_texture(VARIANTS, rect, Vector2i(size / 2)), Rect2(position.round(), size), false, tint)

static func draw_fantasy(canvas: CanvasItem, column: int, row: int, position: Vector2, size: Vector2, tint: Color = Color.WHITE) -> void:
	var dimensions = Vector2(FANTASY.get_width(), FANTASY.get_height())
	var left = [0.0, 0.26, 0.467, 0.768][column] if row == 0 else column / 4.0
	var right = [0.259, 0.466, 0.767, 1.0][column] if row == 0 else (column + 1) / 4.0
	var rect = Rect2(Vector2(left * dimensions.x, 0 if row == 0 else dimensions.y * 0.69), Vector2((right - left) * dimensions.x, dimensions.y * (0.69 if row == 0 else 0.31)))
	canvas.draw_texture_rect(pixel_texture(FANTASY, rect, Vector2i(size / 2)), Rect2(position.round(), size), false, tint)

static func depth_texture(column: int, row: int) -> Texture2D:
	var dimensions = Vector2(DEPTH.get_width(), DEPTH.get_height())
	var left = [0.0, 0.283, 0.513, 0.747][column] if row == 0 else [0.025, 0.37, 0.55, 0.79][column]
	var right = [0.282, 0.512, 0.746, 1.0][column] if row == 0 else [0.295, 0.48, 0.715, 0.95][column]
	var top = 0.0 if row == 0 else 0.635
	var bottom = 0.635 if row == 0 else 1.0
	var rect = Rect2(Vector2(left * dimensions.x, top * dimensions.y), Vector2((right - left) * dimensions.x, (bottom - top) * dimensions.y))
	var target = Vector2i(64, 80) if row == 0 else [Vector2i(48, 30), Vector2i(20, 30), Vector2i(32, 60), Vector2i(32, 44)][column]
	return pixel_texture(DEPTH, rect, target)

static func tree_texture(id: int) -> Texture2D:
	var variant = preload("res://scripts/valley_layout.gd").TREE_VARIANTS[id] if id < 50 else (1 if id < 80 else (2 if id < 96 else 3))
	return depth_texture(variant, 0)

static func tree_occluders(id: int) -> Array:
	var texture=tree_texture(id)
	var key=texture.get_instance_id()
	if not occluder_cache.has(key):
		var bitmap=BitMap.new()
		bitmap.create_from_image_alpha(texture.get_image(),0.5)
		occluder_cache[key]=bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO,texture.get_size()),1.5)
	return occluder_cache[key]

static func prop_texture(family: String, variant: int, frame: int = 0, turns: int = 0) -> Texture2D:
	if family == "camp" and variant == 4:
		var fire = preload("res://scripts/directional_art.gd").sheet_frame("res://assets/art/campfire-v2.png",frame%4,0,4,1,Vector2i(28,28))
		if fire != null:
			return fire
	var rotated = preload("res://scripts/directional_art.gd").prop(family,variant,turns)
	if rotated != null:
		return rotated
	if family == "fence" or family == "lamp":
		return depth_texture(variant if family == "fence" else variant + 2, 1)
	if family == "torch":
		var center = [0.23,0.50,0.77][frame % 3]
		return pixel_texture(TORCH, Rect2(TORCH.get_width() * (center - 0.07), TORCH.get_height() * 0.03, TORCH.get_width() * 0.14, TORCH.get_height() * 0.92), Vector2i(12,40))
	if family == "micro":
		var size = Vector2(MICRO.get_size()) / 4
		return pixel_texture(MICRO, Rect2(Vector2(variant % 4, variant / 4) * size, size), preload("res://scripts/decor_catalog.gd").MICRO_SIZES[variant])
	if family == "camp":
		var sizes = [Vector2i(36,24), Vector2i(36,32), Vector2i(48,30), Vector2i(28,36)]
		return pixel_texture(CAMP, Rect2((variant - 4) * CAMP.get_width() / 4.0, CAMP.get_height() * 0.64, CAMP.get_width() / 4.0, CAMP.get_height() * 0.34), sizes[variant - 4])
	return GRASS

static func draw_oriented(canvas: CanvasItem, texture: Texture2D, turns: int, tint: Color = Color.WHITE) -> void:
	var size = Vector2(texture.get_size()) * 2
	canvas.draw_texture_rect(texture, Rect2(-size.x / 2, -size.y + 8, size.x, size.y), false, tint)
