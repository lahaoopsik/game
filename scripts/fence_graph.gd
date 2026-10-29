extends RefCounted
static func compatible(a: Dictionary,b: Dictionary) -> bool:
	return (a.family=="fence" and b.family=="fence") or (a.family=="camp" and a.variant==6 and b.family=="camp" and b.variant==6)

static func connections(props: Array, prop: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for other in props:
		if other.id==prop.id or other.get("location","outside")!=prop.get("location","outside") or not compatible(prop,other):
			continue
		var offset = Vector2(other.x-prop.x,other.y-prop.y)
		if offset.length() < 20 or offset.length() > (100 if prop.family=="fence" else 58):
			continue
		var horizontal = absf(offset.x)>absf(offset.y)
		if minf(absf(offset.x),absf(offset.y)) > 20:
			continue
		var direction = ("right" if offset.x>0 else "left") if horizontal else ("down" if offset.y>0 else "up")
		if not result.has(direction) or offset.length_squared()<Vector2(result[direction]).length_squared():
			result[direction] = offset
	return result
