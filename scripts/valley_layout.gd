extends RefCounted
## Authored coordinates: no random map generation.
const ID = "sunny-valley-authored-1"
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
	Vector2(2160, 1510), Vector2(2250, 1610), Vector2(2070, 1640)]
const PATHS = [
	[Vector2(590, 1050), Vector2(650, 1070), Vector2(880, 1100), Vector2(1070, 1060), Vector2(1270, 1080), Vector2(1520, 1050), Vector2(1820, 1080), Vector2(2160, 1060)],
	[Vector2(1120, 1060), Vector2(1160, 910), Vector2(1200, 760), Vector2(1210, 560), Vector2(1190, 290)],
	[Vector2(1400, 1070), Vector2(1430, 1190), Vector2(1400, 1400), Vector2(1450, 1650)]]
const FLOWER_BEDS = [Vector2(950, 790), Vector2(1040, 730), Vector2(1450, 800), Vector2(1530, 870), Vector2(820, 1190), Vector2(1370, 1260), Vector2(670, 790)]
const BUSHES = [Vector2(810, 680), Vector2(1000, 540), Vector2(1370, 670), Vector2(1630, 690), Vector2(1970, 980), Vector2(940, 1400), Vector2(1850, 1530), Vector2(200, 730)]
const ROCKS = [Vector2(640, 450), Vector2(600, 520), Vector2(560, 810), Vector2(530, 1280), Vector2(650, 1450), Vector2(1530, 680), Vector2(1620, 1170), Vector2(2100, 1200)]
const FIREFLY_ZONES = [Vector2(640, 500), Vector2(590, 790), Vector2(570, 1230), Vector2(960, 1290), Vector2(1650, 1320)]

static func river_x(y: float) -> float:
	var anchors = [Vector2(410, 0), Vector2(500, 300), Vector2(540, 600), Vector2(450, 950), Vector2(460, 1200), Vector2(570, 1500), Vector2(520, 1800)]
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
