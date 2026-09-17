extends Control
## 4-step card shown 3.0s then hidden. Memory, not RNG.

const STEPS := ["chop", "stir", "sear", "plate", "fold", "zest", "toast", "rest"]

var sequence: Array = []
var hidden: bool = false
var picks: Array = []
var shown_at: float = 0.0


func _ready() -> void:
	$Title.text = "RECIPE MIX"
	$Rafael.text = "Rafael"
	$Back.custom_minimum_size = Vector2(240, 56)
	$Back.pressed.connect(func() -> void: Game.goto("lobby"))
	$Start.custom_minimum_size = Vector2(240, 56)
	$Start.pressed.connect(_deal_card)
	var x := 80
	for s in STEPS:
		var b := Button.new()
		b.text = s
		b.custom_minimum_size = Vector2(160, 52)
		b.position = Vector2(x, 700)
		b.pressed.connect(_pick.bind(s))
		add_child(b)
		x += 180


func _deal_card() -> void:
	if not Game.can_start_mini():
		Game.toast(Game.text("daylight_returns"))
		return
	sequence = []
	## Fixed teaching recipes cycle by recipe count — not ChanceRng.
	var start: int = int(Save.progress.get("recipes", 0)) % STEPS.size()
	for i in 4:
		sequence.append(STEPS[(start + i) % STEPS.size()])
	picks = []
	hidden = false
	$Card.text = " → ".join(PackedStringArray(sequence))
	$Result.text = ""
	shown_at = Time.get_ticks_msec() / 1000.0
	get_tree().create_timer(3.0).timeout.connect(func() -> void:
		hidden = true
		$Card.text = "····"
	)


func _pick(step: String) -> void:
	if sequence.is_empty() or not hidden:
		return
	picks.append(step)
	if picks.size() >= 4:
		_score()


func _score() -> void:
	var ok: int = 0
	for i in 4:
		if i < picks.size() and str(picks[i]) == str(sequence[i]):
			ok += 1
	var pay: int = 5
	if ok == 4:
		pay = 25
		Save.add_recipe()
	elif ok == 3:
		pay = 8
	Economy.add_shells(pay)
	$Result.text = "%d/4   %d Shells" % [ok, pay]
	Save.write_disk()
