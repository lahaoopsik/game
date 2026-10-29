extends RefCounted
const MICRO_NAMES = ["Кувшин", "Табурет", "Корзина", "Свёрнутая подстилка", "Поленница", "Колодка с топором", "Сушилка трав", "Тканевый навес", "Камешки", "Коряга", "Грибы", "Корни", "Камыш", "Кувшинка", "Ведро", "Подвесные листья"]
const MICRO_SIZES = [Vector2i(16,18),Vector2i(16,14),Vector2i(16,16),Vector2i(20,12),Vector2i(24,16),Vector2i(20,20),Vector2i(24,28),Vector2i(28,20),Vector2i(20,12),Vector2i(28,16),Vector2i(16,12),Vector2i(24,18),Vector2i(16,28),Vector2i(20,12),Vector2i(14,18),Vector2i(16,26)]

static func portable(family: String, variant: int) -> bool:
	if family == "micro":
		return variant >= 0 and variant < 16 and variant not in [8,9,10,11,12,13]
	if family=="bench":
		return variant==0
	return (family in ["fence", "lamp"] and variant in [0,1]) or (family == "camp" and variant in [4,5,6,7]) or (family == "torch" and variant == 0)

static func item_id(family: String, variant: int) -> String:
	return "prop:%s:%d" % [family, variant]

static func parse(item: String) -> Dictionary:
	var fields = item.split(":")
	if fields.size() != 3 or fields[0] != "prop" or not fields[2].is_valid_int():
		return {}
	var variant = int(fields[2])
	return {"family": fields[1], "variant": variant} if portable(fields[1], variant) else {}

static func display_name(item: String) -> String:
	var prop = parse(item)
	if prop.is_empty():
		return item
	match prop.family:
		"bench": return "Верстак"
		"micro": return MICRO_NAMES[prop.variant]
		"fence": return "Секция забора"
		"lamp": return "Фонарь-семя" if prop.variant == 0 else "Кристальный фонарь"
		"torch": return "Факел"
		"camp": return ["Кострище", "Припасы", "Повреждённая ограда", "Указатель"][prop.variant - 4]
	return item
