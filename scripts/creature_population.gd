extends Node2D
## Authored habitats. Ambient inhabitants do not mutate inventory or bonds.
var world: Node2D
const HABITATS = [
	[0,Vector2(1100,780),150.0,3],
	[0,Vector2(1350,2450),170.0,2],
	[1,Vector2(1510,1690),150.0,3],
	[1,Vector2(2680,1400),140.0,2],
	[2,Vector2(2910,2010),130.0,4],
	[2,Vector2(1120,1900),120.0,3],
	[3,Vector2(2130,2050),95.0,2],
	[3,Vector2(1920,2250),65.0,2]]

func _ready() -> void:
	y_sort_enabled=true
	var serial=0
	for habitat in HABITATS:
		for i in range(habitat[3]):
			var creature=preload("res://scripts/creature.gd").new()
			creature.world=world
			creature.species=habitat[0]
			creature.home=habitat[1]
			creature.radius=habitat[2]
			creature.serial=serial
			creature.position=creature.home+Vector2.from_angle(i*2.4)*float(i*16)
			for attempt in range(80):
				var candidate=creature.home+Vector2.from_angle(attempt*2.4+serial)*float(12+(attempt%8)*12)
				var query=PhysicsPointQueryParameters2D.new()
				query.position=candidate
				query.collision_mask=1
				if world.state.terrain.material_at(Vector2i(candidate/48))!=7 and get_world_2d().direct_space_state.intersect_point(query).is_empty():
					creature.position=candidate
					break
			add_child(creature)
			serial+=1
