extends Node2D
const Art = preload("res://scripts/art.gd")
const SkinArt = preload("res://scripts/world_art.gd")
var state: RefCounted
var environment: Node
var contents: Node2D
var shell: Texture2D

func _ready() -> void:
	y_sort_enabled=true
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	if ResourceLoader.exists("res://assets/art/native/interior.png"):
		var source: Texture2D=load("res://assets/art/native/interior.png")
		shell=Art.pixel_texture(source,Rect2(Vector2.ZERO,source.get_size()),Vector2i(480,320))
	refresh()

func refresh() -> void:
	if is_instance_valid(contents):
		remove_child(contents)
		contents.queue_free()
	contents=Node2D.new()
	contents.y_sort_enabled=true
	add_child(contents)
	for prop in state.decorations:
		if prop.get("location","outside")!="chief_tent":
			continue
		var view=preload("res://scripts/decor_view.gd").new()
		view.data=prop
		view.state=state
		view.environment=environment
		view.position=Vector2(prop.x,prop.y)
		contents.add_child(view)
	for building in state.buildings:
		if building.get("location","outside")!="chief_tent":
			continue
		var view=SkinArt.new()
		view.kind="bench"
		view.data=building
		view.position=Vector2(building.x,building.y)
		contents.add_child(view)
		if building.work>=4:
			var body=StaticBody2D.new()
			body.position=view.position
			var collision=CollisionShape2D.new()
			var shape=RectangleShape2D.new()
			shape.size=Vector2(48,76) if int(building.get("rotation",0))%2 else Vector2(76,48)
			collision.shape=shape
			body.add_child(collision)
			contents.add_child(body)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-600,-400,2160,1440),Color("382f29"))
	if shell!=null:
		draw_texture_rect(shell,Rect2(0,0,960,640),false)
	else:
		draw_rect(Rect2(60,60,840,540),Color("ac8d61"))
		draw_rect(Rect2(60,60,840,24),Color("726b46"))
	draw_rect(Rect2(448,590,64,20),Color("b58b56"))
