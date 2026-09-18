extends Control
## Tiki Lounge is the locked interior painting. Reels sit in the cabinets.

const ROOM := "res://art/seasons/paloma/refs/image-498ab62c-b49d-4719-8efa-0b0af2992a8d.jpg"

var bet: int = 1
var last: Dictionary = {}
var spinning: bool = false
var _mode: String = "palm"
var _cells: Array = []
var _credits: Label
var _result: Label
var _name: Label
var _shot_path: String = ""
var _shot_frames: int = 0


func _ready() -> void:
	_build()
	_hud()
	_shot_path = OS.get_environment("PALM_SHOT")
	set_process(true)


func _process(_delta: float) -> void:
	if _shot_path == "":
		return
	_shot_frames += 1
	if _shot_frames == 16:
		get_viewport().get_texture().get_image().save_png(_shot_path)
		print("PALM_SHOT ", _shot_path)
		get_tree().quit()


func _build() -> void:
	var photo := TextureRect.new()
	photo.set_anchors_preset(Control.PRESET_FULL_RECT)
	photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	photo.texture = load(ROOM)
	photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(photo)
	_name = _lbl(Vector2(0, 12), Vector2(1920, 44), "SLOTS — FOR FUN", 28)
	_credits = _lbl(Vector2(0, 52), Vector2(1920, 32), "", 18)
	_result = _lbl(Vector2(0, 980), Vector2(1920, 40), "", 22)
	var grid := GridContainer.new()
	grid.columns = 5
	## Sit the 5×3 reels on the left tiki cabinet window of the painting.
	grid.position = Vector2(168, 390)
	add_child(grid)
	_cells = [[], [], [], [], []]
	for row in 3:
		for col in 5:
			var tr := TextureRect.new()
			tr.custom_minimum_size = Vector2(52, 52)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.texture = load("res://art/seasons/paloma/sym_L.png")
			grid.add_child(tr)
			_cells[col].append(tr)
	_btn(Vector2(860, 900), Vector2(200, 64), "Spin", _spin)
	_btn(Vector2(24, 1000), Vector2(160, 52), "Back", func() -> void: Game.leave_chance_room())
	_btn(Vector2(700, 980), Vector2(72, 48), "1", func() -> void: bet = 1; _hud())
	_btn(Vector2(780, 980), Vector2(72, 48), "5", func() -> void: bet = 5; _hud())
	_btn(Vector2(860, 980), Vector2(72, 48), "25", func() -> void: bet = 25; _hud())
	_btn(Vector2(940, 980), Vector2(72, 48), "50", func() -> void: bet = 50; _hud())
	_btn(Vector2(1480, 1000), Vector2(140, 48), "Reels", func() -> void: _mode = "palm"; _name.text = "PALM REELS"; _hud())
	_btn(Vector2(1630, 1000), Vector2(140, 48), "Wheel", func() -> void: _mode = "wheel"; _name.text = "COCONUT WHEEL"; _hud())
	_btn(Vector2(1780, 1000), Vector2(120, 48), "Dive", func() -> void: _mode = "dive"; _name.text = "LAGOON DIVE"; _hud())


func _lbl(pos: Vector2, sz: Vector2, text: String, size: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = sz
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("#F7F1E3"))
	l.add_theme_color_override("font_outline_color", Color("#1B1B1B"))
	l.add_theme_constant_override("outline_size", 6)
	add_child(l)
	return l


func _btn(pos: Vector2, sz: Vector2, text: String, cb: Callable) -> void:
	var b := Button.new()
	b.position = pos
	b.size = sz
	b.text = text
	b.pressed.connect(cb)
	add_child(b)


func _hud() -> void:
	_credits.text = "%d credits   bet %d" % [Economy.hud_amount(), bet]


func _spin() -> void:
	if spinning:
		return
	var cost: int = CoconutWheel.COST if _mode == "wheel" else bet
	if not PlaySafe.chance_staking_allowed():
		Game.toast(Game.text("cool_off_on"))
		return
	if not Game.can_spin_or_deal():
		Game.toast(Game.text("daylight_returns"))
		return
	if not Economy.spend_shells(cost):
		_result.text = "Not enough"
		return
	Economy.record_spin(0)
	spinning = true
	Game.play_sfx("click")
	match _mode:
		"palm":
			last = PalmReels.play(bet)
		"wheel":
			last = CoconutWheel.play()
		"dive":
			last = LagoonDive.play(bet)
	for _i in 12:
		_scramble()
		await get_tree().create_timer(0.04).timeout
	if _mode == "palm":
		_show_window(last.get("first", {}).get("window", []))
	var total: int = int(last.get("total", 0))
	if total > 0:
		Economy.add_shells(total)
	_result.text = "+%d   net %d" % [total, int(last.get("net", 0))]
	if bool(last.get("celebrate", false)):
		Game.play_sfx("win")
	_hud()
	Save.write_disk()
	spinning = false


func _scramble() -> void:
	var keys := ["P", "C", "H", "S", "L", "W", "B"]
	for col in _cells:
		for cell in col:
			(cell as TextureRect).texture = _tex(keys[randi() % keys.size()])


func _show_window(window: Array) -> void:
	if window.size() < 5:
		return
	for c in 5:
		var col: Array = window[c]
		for r in mini(3, col.size()):
			(_cells[c][r] as TextureRect).texture = _tex(str(col[r]))


func _tex(sym: String) -> Texture2D:
	var path := "res://art/seasons/paloma/sym_%s.png" % sym
	if ResourceLoader.exists(path):
		return load(path)
	return load("res://art/seasons/paloma/sym_L.png")
