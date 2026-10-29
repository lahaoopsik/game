extends Control
const FONT = preload("res://assets/fonts/PressStart2P-Regular.ttf")
var state: RefCounted
var player_position = Vector2.ZERO
var texture: Texture2D
const AREA = Rect2(60,10,696,520)

func _ready() -> void:
	custom_minimum_size = Vector2(816,540)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func refresh(new_state: RefCounted) -> void:
	state = new_state
	var image = Image.create(state.terrain.SIZE.x,state.terrain.SIZE.y,false,Image.FORMAT_RGBA8)
	var palette = [Color("6ca653"),Color("e6ce8d"),Color("a4a697"),Color("d4ab70"),Color("8d7255"),Color("a6a18c"),Color("c59571"),Color("77bdcb")]
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var cell = Vector2i(x,y)
			var color: Color = palette[state.terrain.material_at(cell)]
			color = color.darkened(state.terrain.elevation_at(cell) * 0.06)
			image.set_pixel(x,y,color)
	texture = ImageTexture.create_from_image(image)
	queue_redraw()

func point(p: Vector2) -> Vector2:
	return AREA.position + p / state.WORLD_SIZE * AREA.size

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func _draw() -> void:
	if texture == null or state == null:
		return
	draw_texture_rect(texture,AREA,false)
	draw_rect(AREA.grow(2),Color("835c36"),false,2)
	for tree in state.trees:
		draw_rect(Rect2(point(Vector2(tree.x,tree.y))-Vector2.ONE,Vector2(3,3)),Color("3d7443"))
	var landmarks = [[Vector2(570,1050),"МОСТ"],[Vector2(2100,2050),"ГОБЛИНЫ"],[Vector2(1200,950),"ПОЛЯНА"],[Vector2(3560,1010),"СКАЛЫ"],[Vector2(2900,680),"ЛЕС"]]
	for entry in landmarks:
		var p = point(entry[0])
		draw_rect(Rect2(p-Vector2(3,3),Vector2(6,6)),Color("f6dfb0"))
		draw_string(FONT,p+Vector2(6,-5),entry[1],HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("4d3628"))
	var player = point(player_position)
	draw_rect(Rect2(player-Vector2(4,4),Vector2(8,8)),Color("fff5d0"))
	draw_rect(Rect2(player-Vector2(2,2),Vector2(4,4)),Color("b94b38"))
