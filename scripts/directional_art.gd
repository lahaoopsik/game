extends RefCounted
## Real front/side/rear sheets. No mirroring is used to manufacture a missing view.
static var cache: Dictionary = {}
static var row_scales: Dictionary = {}
static var source_images: Dictionary = {}
const ROOT = "res://assets/art/"

static func direction_index(direction: Vector2) -> int:
	if absf(direction.x) > absf(direction.y):
		return 2 if direction.x < 0 else 3
	return 1 if direction.y < 0 else 0

static func sheet_frame(path: String, column: int, row: int, columns: int, rows: int, native: Vector2i) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var key = "%s:%d:%d:%s" % [path,column,row,native]
	if cache.has(key):
		return cache[key]
	var texture: Texture2D = load(path)
	if not source_images.has(path):
		source_images[path]=texture.get_image()
		if path.ends_with("creatures-v1.png"):
			var clean: Image=source_images[path]
			for y in range(clean.get_height()):
				for x in range(clean.get_width()):
					var pixel=clean.get_pixel(x,y)
					if pixel.a<0.4:
						clean.set_pixel(x,y,Color.TRANSPARENT)
	var source: Image = source_images[path]
	var cell_size = Vector2i(source.get_width() / columns, source.get_height() / rows)
	var scale_key = "%s:%d:%s" % [path,row,native]
	if not row_scales.has(scale_key):
		var max_size = Vector2.ONE
		for i in range(columns):
			var cell = source.get_region(Rect2i(Vector2i(i,row) * cell_size, cell_size))
			var used = cell.get_used_rect().size
			max_size = max_size.max(Vector2(used))
		row_scales[scale_key] = minf(native.x / max_size.x, native.y / max_size.y)
	var image = source.get_region(Rect2i(Vector2i(column,row) * cell_size, cell_size))
	var used = image.get_used_rect()
	var result = Image.create(native.x,native.y,false,Image.FORMAT_RGBA8)
	if used.has_area():
		image = image.get_region(used)
		var target = Vector2i(Vector2(used.size) * float(row_scales[scale_key])).max(Vector2i.ONE)
		image.resize(target.x,target.y,Image.INTERPOLATE_NEAREST)
		result.blit_rect(image,Rect2i(Vector2i.ZERO,target),Vector2i((native.x-target.x)/2,native.y-target.y))
	var final = ImageTexture.create_from_image(result)
	cache[key] = final
	return final

static func prop(family: String, variant: int, turns: int) -> Texture2D:
	var group = ""
	var row = 0
	var native = Vector2i(24,24)
	var rows = 4
	match family:
		"bench": group="rotation-a-v1.png"; row=0; native=Vector2i(48,40)
		"lamp": group="rotation-a-v1.png"; row=variant+1; native=Vector2i(32,60) if variant==0 else Vector2i(32,44)
		"torch": group="rotation-a-v1.png"; row=3; native=Vector2i(12,40)
		"micro":
			if variant < 4: group="rotation-b-v1.png"; row=variant
			elif variant < 8: group="rotation-c-v1.png"; row=variant-4
			elif variant in [14,15]: group="rotation-d-v1.png"; row=variant-14
			else: return null
			native=preload("res://scripts/decor_catalog.gd").MICRO_SIZES[variant]
		"camp":
			if variant in [4,5]: group="rotation-d-v1.png"; row=variant-2; native=Vector2i(36,32)
			elif variant in [6,7]: group="rotation-e-v1.png"; rows=3; row=variant-5; native=Vector2i(48,30) if variant==6 else Vector2i(28,36)
		"fence": group="rotation-e-v1.png"; rows=3; row=0; native=Vector2i(48,30); turns=(turns+variant)%4
	if group == "":
		return null
	return sheet_frame(ROOT+group,turns%4,row,4,rows,native)
