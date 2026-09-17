extends Control
## 8 buoys. Timing / hold-to-steer. Gates do not move after spawn. Miss decided by input.

var gates: Array = []
var hits: int = 0
var running: bool = false
var t: float = 0.0
var x: float = 0.5
var finished: bool = false


func _ready() -> void:
	$Title.text = "JET-SKI SLALOM"
	$Mateo.text = "Mateo"
	$Back.custom_minimum_size = Vector2(240, 56)
	$Start.custom_minimum_size = Vector2(240, 56)
	$Back.pressed.connect(func() -> void: Game.goto("island"))
	$Start.pressed.connect(_start)
	_spawn()


func _spawn() -> void:
	gates = []
	for i in 8:
		gates.append({"x": 0.2 + float(i % 3) * 0.25, "t": 0.8 + float(i) * 0.7, "hit": false})


func _start() -> void:
	if not Game.can_start_mini():
		Game.toast(Game.text("daylight_returns"))
		return
	hits = 0
	t = 0.0
	x = 0.5
	finished = false
	running = true
	_spawn()
	$Result.text = ""


func _process(delta: float) -> void:
	if not running:
		return
	t += delta
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_action_pressed("ui_right"):
		x = minf(1.0, x + delta * 0.7)
	if Input.is_action_pressed("ui_left"):
		x = maxf(0.0, x - delta * 0.7)
	$Craft.position.x = 80 + x * 1600.0
	for g in gates:
		if not g["hit"] and abs(t - float(g["t"])) < 0.18:
			if abs(x - float(g["x"])) < 0.12:
				g["hit"] = true
				hits += 1
	if t > 7.2:
		_finish()


func _finish() -> void:
	if finished:
		return
	finished = true
	running = false
	var pay: int = 20
	if hits == 8:
		pay = 35
	elif hits <= 5:
		pay = 8
	Economy.add_shells(pay)
	$Result.text = "Gates %d/8   %d Shells" % [hits, pay]
	Save.write_disk()
