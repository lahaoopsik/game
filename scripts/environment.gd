extends Node
## Visual time only; no changes to residents, growth or resource rules.
const CYCLE_SECONDS = 720.0
var phase = 0.32
var tint: CanvasModulate
var clock: Label
var day = 1
var indoors = false

func _ready() -> void:
	tint = CanvasModulate.new()
	add_child(tint)
	update_light()

func _process(delta: float) -> void:
	advance_time(delta / CYCLE_SECONDS)
	update_light()

func advance_quarter_day() -> void:
	advance_time(0.25)
	update_light()

func advance_time(amount: float) -> void:
	var total = phase + amount
	day += int(floor(total))
	phase = fposmod(total, 1.0)

func update_light() -> void:
	var stops = [0.0, 0.20, 0.27, 0.34, 0.65, 0.75, 0.83, 1.0]
	var colors = [Color("444c7c"), Color("444c7c"), Color("d6a799"), Color("ffffff"), Color("ffffff"), Color("e5b08a"), Color("444c7c"), Color("444c7c")]
	for i in range(stops.size() - 1):
		if phase >= stops[i] and phase <= stops[i + 1]:
			tint.color = colors[i].lerp(colors[i + 1], smoothstep(stops[i], stops[i + 1], phase))
			break
	var minutes = int(phase * 1440)
	if indoors:
		tint.color=Color("e5d7b8")
	var period = "НОЧЬ" if phase < 0.22 or phase >= 0.83 else ("УТРО" if phase < 0.36 else ("ДЕНЬ" if phase < 0.70 else "ВЕЧЕР"))
	if is_instance_valid(clock):
		clock.text = "ДЕНЬ %d\n%02d:%02d" % [day, minutes / 60, minutes % 60]

func snapshot() -> Dictionary:
	return {"phase": phase, "day": day}

func restore(data: Dictionary) -> void:
	phase = fposmod(float(data.get("phase", 0.32)), 1.0)
	day = maxi(1, int(data.get("day", 1)))
	update_light()
