extends Control

var playing: bool = false
var t: float = 0.0
var last: Dictionary = {}


func _ready() -> void:
	$Plate.text = Game.text("door_tide")
	$Parts.text = "Parts %d/6" % TideRules.parts()
	$Crank.custom_minimum_size = Vector2(240, 56)
	$Back.custom_minimum_size = Vector2(240, 56)
	$Crank.pressed.connect(_crank)
	$Back.pressed.connect(func() -> void: Game.goto("island"))
	_draw_parts()


func _draw_parts() -> void:
	$Chain.text = " → ".join(PackedStringArray(TideRules.PART_ORDER.slice(0, TideRules.parts())))
	if TideRules.parts() == 0:
		$Chain.text = "No parts yet"


func _crank() -> void:
	if playing:
		return
	last = TideRules.crank()
	if not bool(last.get("ok", false)):
		$Result.text = Game.text("tide_unfinished")
		return
	playing = true
	t = 0.0
	$Result.text = "Turning…"


func _process(delta: float) -> void:
	if not playing:
		return
	t += delta
	if t >= TideRules.CRANK_SECONDS:
		playing = false
		$Result.text = "40 Shells"
		$Parts.text = "Parts %d/6" % TideRules.parts()
	elif bool(last.get("unskippable", true)):
		pass
	elif Input.is_action_just_pressed("walk") or Input.is_action_just_pressed("ui_accept"):
		playing = false
		$Result.text = "40 Shells"
