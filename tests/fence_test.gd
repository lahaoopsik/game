extends SceneTree
func _initialize() -> void:
	var graph=preload("res://scripts/fence_graph.gd")
	var a={"id":"a","family":"fence","variant":0,"x":24,"y":24}
	var b={"id":"b","family":"fence","variant":0,"x":72,"y":24}
	var c={"id":"c","family":"fence","variant":1,"x":24,"y":72}
	var connections=graph.connections([a,b,c],a)
	assert(connections.has("right") and connections.has("down"))
	assert(not graph.connections([a,c],a).has("right"))
	print("PASS: fence side connections, corner connections and recomputation after removal")
	quit()
