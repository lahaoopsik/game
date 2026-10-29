extends RefCounted
## Authored coordinates: no random map generation.
const ID = "sunny-valley-authored-1"
const WORLD_SIZE = Vector2(4176, 3120)
const REVISION = 2
const VILLAGE = [Vector3(2120, 1880, 0), Vector3(1880, 2050, 1), Vector3(2350, 2050, 2), Vector3(2340, 2250, 3), Vector3(2120, 2090, 4), Vector3(1990, 1950, 5), Vector3(1790, 2180, 6), Vector3(2430, 1900, 7)]
const VILLAGE_FIELDS = [Rect2(1760, 2280, 192, 144), Rect2(2000, 2320, 144, 96)]
const MICRO_PROPS = [
	# Chief's entrance and shared fire: water, seating, blankets, firewood.
	Vector3(2010,1885,0),Vector3(2210,1885,1),Vector3(2020,1910,3),
	Vector3(2050,2130,1),Vector3(2200,2135,1),Vector3(2210,2185,4),Vector3(2250,2170,5),
	# Tent thresholds and a quiet work corner.
	Vector3(1830,2070,14),Vector3(1820,1990,3),Vector3(1920,2100,2),
	Vector3(2390,2080,0),Vector3(2420,2010,6),Vector3(2460,2050,7),Vector3(2290,1970,15),
	Vector3(2370,2260,3),Vector3(2420,2280,4),Vector3(1950,1950,2),
	# Field-side tools and harvest baskets, leaving the plot rows clear.
	Vector3(1725,2300,14),Vector3(1740,2400,2),Vector3(1960,2360,0),Vector3(2180,2390,2),
	# Bridge landing and riverbank. Natural items are not collectible furniture.
	Vector3(310,1105,14),Vector3(655,1130,5),Vector3(655,1160,4),Vector3(585,950,15),
	Vector3(390,900,8),Vector3(570,730,12),Vector3(355,1330,9),Vector3(610,1510,12),
	# Meadow groves and the small pond.
	Vector3(840,700,11),Vector3(955,600,10),Vector3(1410,620,11),Vector3(1560,720,10),
	Vector3(985,1740,13),Vector3(1035,1780,13),Vector3(1110,1770,12),Vector3(880,1690,9),
	# Ridge and lakeside details follow the banks and trail corners.
	Vector3(3310,1180,8),Vector3(3450,1070,8),Vector3(3640,970,11),Vector3(3930,1230,8),
	Vector3(2860,1720,13),Vector3(3020,1800,13),Vector3(3150,1730,13),Vector3(3250,1820,12),
	Vector3(2780,1640,9),Vector3(2950,1940,12),Vector3(3210,1930,8),
	# Southern forest: fallen wood, roots and fungi form small contextual groups.
	Vector3(1080,2010,10),Vector3(1190,2210,11),Vector3(1310,2720,9),
	Vector3(2780,2180,11),Vector3(2820,2220,10),Vector3(3150,2290,9),Vector3(3320,2710,10),
	Vector3(2680,530,11),Vector3(2720,570,10),Vector3(3130,630,9)]
const CAMP_FENCE = [Vector2(1780,1760),Vector2(1870,1745),Vector2(1960,1740),Vector2(2260,1740),Vector2(2350,1750),Vector2(2440,1765),Vector2(1735,1900),Vector2(1730,2040),Vector2(1745,2170),Vector2(2450,2120),Vector2(2470,2300),Vector2(2380,2440),Vector2(2275,2450),Vector2(2180,2450)]
const CAMP_TORCHES = [Vector2(2400,1850),Vector2(2500,1850),Vector2(2000,1900),Vector2(2240,1900),Vector2(1750,2260),Vector2(2180,2290)]
const CHIEF_INTERIOR = [Vector3(330,210,0),Vector3(430,330,1),Vector3(530,330,1),Vector3(700,230,2),Vector3(230,390,3),Vector3(680,430,4),Vector3(700,180,6),Vector3(480,110,15)]

static func decorations() -> Array:
	var result: Array = []
	for i in range(MICRO_PROPS.size()):
		var p: Vector3 = MICRO_PROPS[i]
		result.append({"id": "micro:%d" % i, "family":"micro", "variant":int(p.z), "x":p.x, "y":p.y})
	for group in [FENCES, LAMPS]:
		var family = "fence" if group == FENCES else "lamp"
		for i in range(group.size()):
			var p: Vector3 = group[i]
			result.append({"id":"%s:%d" % [family,i], "family":family, "variant":int(p.z), "x":p.x, "y":p.y})
	for p in VILLAGE:
		if p.z >= 4:
			result.append({"id":"camp:%d" % int(p.z),"family":"camp","variant":int(p.z),"x":p.x,"y":p.y})
	for i in range(CAMP_FENCE.size()):
		result.append({"id":"palisade:%d" % i,"family":"camp","variant":6,"x":CAMP_FENCE[i].x,"y":CAMP_FENCE[i].y})
	for i in range(CAMP_TORCHES.size()):
		result.append({"id":"torch:%d" % i,"family":"torch","variant":0,"x":CAMP_TORCHES[i].x,"y":CAMP_TORCHES[i].y})
	for i in range(CHIEF_INTERIOR.size()):
		var prop: Vector3 = CHIEF_INTERIOR[i]
		result.append({"id":"inside:%d" % i,"family":"micro","variant":int(prop.z),"x":prop.x,"y":prop.y,"location":"chief_tent"})
	result.append({"id":"inside:fire","family":"camp","variant":4,"x":480,"y":430,"location":"chief_tent"})
	result.append({"id":"inside:lamp","family":"lamp","variant":0,"x":240,"y":220,"location":"chief_tent"})
	result.append({"id":"inside:table","family":"bench","variant":0,"x":480,"y":265,"location":"chief_tent"})
	return result
const GRASS_PATCHES = [Vector2(950, 870), Vector2(1420, 930), Vector2(1620, 760), Vector2(890, 1220), Vector2(1300, 1500), Vector2(2030, 1560), Vector2(2310, 710), Vector2(2720, 1030), Vector2(3150, 820), Vector2(1360, 2120), Vector2(1700, 2200), Vector2(2130, 2660), Vector2(2900, 2280), Vector2(3420, 2490)]
const TREE_VARIANTS = [0,0,2,2,0,2,2, 0,0,2,2,0,3,3, 3,2,2, 1,1,1,1,1,1,1, 0,0,2,2,0,2,0, 0,0,2,2,1,1,1, 0,0,2, 2,2,0, 1,1,1, 1,1,1]
const FENCES = [Vector3(650, 1025, 0), Vector3(734, 1040, 0), Vector3(820, 1050, 0), Vector3(920, 890, 1), Vector3(920, 940, 1), Vector3(1450, 1300, 0), Vector3(1534, 1300, 0)]
const LAMPS = [Vector3(585, 1000, 0), Vector3(585, 1110, 0), Vector3(1095, 980, 0), Vector3(1250, 760, 0), Vector3(1430, 1250, 1), Vector3(1710, 1120, 1)]

static func bridge_center() -> Vector2:
	return Vector2(river_x(1050), 1050)

static func is_bridge(p: Vector2) -> bool:
	return Rect2(bridge_center() - Vector2(150, 42), Vector2(300, 84)).has_point(p)

static func is_village_reserved(p: Vector2) -> bool:
	for prop in VILLAGE:
		if prop.z>=4:
			continue
		var size = Vector2(220, 160) if prop.z == 0 else Vector2(150, 100)
		if Rect2(Vector2(prop.x, prop.y) - Vector2(size.x / 2, size.y), size + Vector2(0, 35)).has_point(p):
			return true
	for field in VILLAGE_FIELDS:
		if field.grow(20).has_point(p):
			return true
	return false
const TREES = [
	Vector2(790, 480), Vector2(870, 435), Vector2(960, 490), Vector2(1050, 430),
	Vector2(830, 590), Vector2(950, 620), Vector2(1070, 550),
	Vector2(1330, 470), Vector2(1430, 420), Vector2(1540, 475), Vector2(1620, 410),
	Vector2(1390, 590), Vector2(1510, 610), Vector2(1660, 550),
	Vector2(805, 790), Vector2(735, 850), Vector2(815, 960),
	Vector2(1740, 800), Vector2(1830, 740), Vector2(1930, 795), Vector2(2050, 735),
	Vector2(1780, 910), Vector2(1920, 895), Vector2(2070, 850),
	Vector2(930, 1290), Vector2(1040, 1340), Vector2(1140, 1275), Vector2(1230, 1360),
	Vector2(1000, 1460), Vector2(1150, 1490), Vector2(1300, 1480),
	Vector2(1540, 1260), Vector2(1640, 1320), Vector2(1740, 1240), Vector2(1820, 1350),
	Vector2(1640, 1450), Vector2(1790, 1480), Vector2(1930, 1440),
	Vector2(160, 390), Vector2(250, 450), Vector2(170, 580),
	Vector2(130, 1130), Vector2(230, 1220), Vector2(150, 1360),
	Vector2(2170, 340), Vector2(2250, 460), Vector2(2150, 590),
	Vector2(2160, 1510), Vector2(2250, 1610), Vector2(2070, 1640),
	# Northern evergreen forest: frames the trail, keeps its central corridor open.
	Vector2(2450, 380), Vector2(2540, 440), Vector2(2660, 360), Vector2(2770, 420),
	Vector2(2500, 560), Vector2(2610, 620), Vector2(2750, 540), Vector2(2850, 620),
	Vector2(2940, 390), Vector2(3070, 450), Vector2(3200, 380), Vector2(3340, 460),
	Vector2(3020, 590), Vector2(3160, 640), Vector2(3310, 580),
	Vector2(2470, 880), Vector2(2570, 960), Vector2(2720, 900),
	Vector2(3100, 940), Vector2(3230, 900), Vector2(3360, 980),
	# Eastern ridge: sparse trees and generous space for future stone and ore.
	Vector2(3610, 760), Vector2(3730, 700), Vector2(3920, 850),
	Vector2(3650, 1350), Vector2(3870, 1430), Vector2(4020, 1280),
	Vector2(3400, 1640), Vector2(3550, 1710), Vector2(3850, 1770),
	# Southern flowering groves around a large usable meadow.
	Vector2(1020, 1990), Vector2(1130, 2050), Vector2(1250, 1980),
	Vector2(980, 2170), Vector2(1100, 2250), Vector2(1260, 2150),
	Vector2(1650, 2070), Vector2(1780, 2140), Vector2(1880, 2050),
	Vector2(1740, 2290), Vector2(1900, 2250),
	Vector2(1250, 2690), Vector2(1390, 2770), Vector2(1540, 2700),
	Vector2(1710, 2780), Vector2(1900, 2730),
	# Quiet southeastern grove around a fantasy landmark, not a random mix.
	Vector2(2580, 2040), Vector2(2730, 2110), Vector2(2850, 2040),
	Vector2(2600, 2240), Vector2(2750, 2310), Vector2(2930, 2230),
	Vector2(3170, 2260), Vector2(3300, 2170), Vector2(3450, 2280),
	Vector2(2730, 2680), Vector2(2870, 2750), Vector2(3040, 2690),
	Vector2(3240, 2780), Vector2(3420, 2670),
	Vector2(3750, 2350), Vector2(3930, 2410), Vector2(3800, 2720)]
const PATHS = [
	[Vector2(540, 1050), Vector2(650, 1070), Vector2(880, 1100), Vector2(1070, 1060), Vector2(1270, 1080), Vector2(1520, 1050), Vector2(1820, 1080), Vector2(2160, 1060), Vector2(2400, 1180), Vector2(2710, 1250), Vector2(3020, 1240), Vector2(3380, 1190), Vector2(3700, 1110)],
	[Vector2(1120, 1060), Vector2(1160, 910), Vector2(1200, 760), Vector2(1210, 560), Vector2(1190, 290)],
	[Vector2(1400, 1070), Vector2(1430, 1190), Vector2(1400, 1400), Vector2(1450, 1650), Vector2(1490, 1900), Vector2(1450, 2230), Vector2(1540, 2480), Vector2(1700, 2700)],
	[Vector2(2690, 1250), Vector2(2810, 1010), Vector2(2910, 800), Vector2(2900, 520)],
	[Vector2(2400, 1180), Vector2(2420, 1590), Vector2(2490, 1890), Vector2(2900, 1990), Vector2(3100, 2170), Vector2(3120, 2470), Vector2(3300, 2670)],
	[Vector2(1450, 2230), Vector2(1850, 2430), Vector2(2200, 2440), Vector2(2600, 2480), Vector2(3120, 2470)]]

static func grass_clumps() -> Array:
	var clumps: Array = []
	for patch_index in range(GRASS_PATCHES.size()):
		for row in range(5):
			for column in range(7):
				var offset = Vector2((column - 3) * 26 + (row % 2) * 12, (row - 2) * 20)
				if (offset / Vector2(95, 48)).length_squared() < 1:
					var p: Vector2 = GRASS_PATCHES[patch_index] + offset
					clumps.append({"id": "%d:%d:%d" % [patch_index, row, column], "x": p.x, "y": p.y, "variant": (column + row) % 4})
	return clumps
const FLOWER_BEDS = [Vector2(950, 790), Vector2(1040, 730), Vector2(1450, 800), Vector2(1530, 870), Vector2(820, 1190), Vector2(1370, 1260), Vector2(670, 790), Vector2(1360, 2130), Vector2(1650, 2330), Vector2(2030, 2530), Vector2(2810, 2170), Vector2(3250, 2410)]
const BUSHES = [Vector2(810, 680), Vector2(1000, 540), Vector2(1370, 670), Vector2(1630, 690), Vector2(1970, 980), Vector2(940, 1400), Vector2(1850, 1530), Vector2(200, 730)]
const ROCKS = [Vector2(640, 450), Vector2(600, 520), Vector2(560, 810), Vector2(530, 1280), Vector2(650, 1450), Vector2(1530, 680), Vector2(1620, 1170), Vector2(2100, 1200)]
const FIREFLY_ZONES = [Vector2(640, 500), Vector2(590, 790), Vector2(570, 1230), Vector2(960, 1290), Vector2(1650, 1320),Vector2(2840,1660),Vector2(3170,1850),Vector2(2110,2130),Vector2(2790,590),Vector2(3240,2680)]

static func river_x(y: float) -> float:
	var anchors = [Vector2(410, 0), Vector2(500, 300), Vector2(540, 600), Vector2(450, 950), Vector2(460, 1200), Vector2(570, 1500), Vector2(520, 1800), Vector2(660, 2170), Vector2(590, 2540), Vector2(740, 3120)]
	for i in range(anchors.size() - 1):
		if y <= anchors[i + 1].y:
			return lerpf(anchors[i].x, anchors[i + 1].x, smoothstep(anchors[i].y, anchors[i + 1].y, y))
	return anchors[-1].x

static func grass_positions() -> Array:
	var positions: Array = []
	for center in FLOWER_BEDS:
		for i in range(24):
			var angle = i * 2.4
			var radius = sqrt(float(i)) * 10
			positions.append(center + Vector2(cos(angle) * radius * 1.5, sin(angle) * radius))
	return positions
