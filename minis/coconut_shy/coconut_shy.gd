extends Control
## 6 coconuts, 8 throws. Drag-release. Deterministic physics for the same aim vector.

var coconuts: Array = []
var throws_left: int = 8
var hits: int = 0
var dragging: bool = false
var drag_from := Vector2.ZERO


func _ready() -> void:
	$Title.text = "COCONUT SHY"
	$Back.custom_minimum_size = Vector2(240, 56)
	$Back.pressed.connect(func() -> void: Game.goto("island"))
	$Bg.anchor_bottom = 0.0
	$Bg.offset_bottom = 140.0
	_reset()


func _reset() -> void:
	coconuts = []
	for i in 6:
		coconuts.append({"x": 400 + i * 180, "y": 360, "up": true})
	throws_left = 8
	hits = 0
	$Result.text = ""


func _draw() -> void:
	for c in coconuts:
		var col := Color(0.47, 0.28, 0.14) if bool(c["up"]) else Color(0.47, 0.28, 0.14, 0.25)
		draw_circle(Vector2(float(c["x"]), float(c["y"])), 48.0, col)
		if bool(c["up"]):
			draw_circle(Vector2(float(c["x"]) - 8.0, float(c["y"]) - 6.0), 8.0, Color(0.12, 0.12, 0.12))
			draw_circle(Vector2(float(c["x"]) + 10.0, float(c["y"]) - 10.0), 8.0, Color(0.12, 0.12, 0.12))
			draw_circle(Vector2(float(c["x"]), float(c["y"]) + 8.0), 8.0, Color(0.12, 0.12, 0.12))
	draw_circle(Vector2(960, 820), 28.0, Color(0.11, 0.11, 0.11))


func _process(_delta: float) -> void:
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT:
			if e.pressed:
				dragging = true
				drag_from = e.position
			elif dragging:
				dragging = false
				_throw(e.position - drag_from)


func _throw(vec: Vector2) -> void:
	if throws_left <= 0:
		return
	if not Game.can_start_mini() and hits == 0 and throws_left == 8:
		Game.toast(Game.text("daylight_returns"))
		return
	throws_left -= 1
	## Deterministic: same vector always hits the same coconut index.
	var aim_x: float = clampf(960.0 + vec.x * 1.4, 300.0, 1500.0)
	for c in coconuts:
		if not bool(c["up"]):
			continue
		if abs(float(c["x"]) - aim_x) < 70.0 and vec.y < -40.0:
			c["up"] = false
			hits += 1
			break
	if throws_left == 0 or hits == 6:
		_payout()


func _payout() -> void:
	var pay: int = hits * 4
	if hits == 6:
		pay += 15
	if hits == 0:
		pay = 5
	Economy.add_shells(pay)
	$Result.text = "%d/6   %d Shells" % [hits, pay]
	Save.write_disk()
