extends Control
## Sit at Palm Reels — rich cabinet face, playable 5×3.

const CAB := "res://art/seasons/paloma/cabinet_palm.jpg"

var bet: int = 1
var last: Dictionary = {}
var spinning: bool = false
var _cells: Array = []
var _credits: Label
var _result: Label
var _win_flash: ColorRect
var _shot_path: String = ""
var _shot_frames: int = 0


func _ready() -> void:
	_build()
	Economy.enter_table_room()
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
	# Dim room behind the machine
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.03, 0.02)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	# Cabinet face — the rich image
	var cab := TextureRect.new()
	cab.set_anchors_preset(Control.PRESET_FULL_RECT)
	cab.offset_left = 280
	cab.offset_right = -280
	cab.offset_top = 20
	cab.offset_bottom = -40
	cab.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cab.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cab.texture = load(CAB)
	cab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cab)
	# Reel window — locked into the cabinet's black glass
	var window := Panel.new()
	window.name = "ReelWindow"
	window.set_anchors_preset(Control.PRESET_CENTER)
	window.offset_left = -200
	window.offset_right = 200
	window.offset_top = -268
	window.offset_bottom = -28
	var wb := StyleBoxFlat.new()
	wb.bg_color = Color(0.02, 0.02, 0.02, 0.55)
	wb.set_border_width_all(2)
	wb.border_color = Color(0.45, 0.28, 0.12, 0.8)
	wb.set_corner_radius_all(6)
	window.add_theme_stylebox_override("panel", wb)
	add_child(window)
	var grid := GridContainer.new()
	grid.columns = 5
	grid.set_anchors_preset(Control.PRESET_FULL_RECT)
	grid.offset_left = 12
	grid.offset_right = -12
	grid.offset_top = 12
	grid.offset_bottom = -12
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	window.add_child(grid)
	_cells = [[], [], [], [], []]
	for row in 3:
		for col in 5:
			var tr := TextureRect.new()
			tr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			tr.size_flags_vertical = Control.SIZE_EXPAND_FILL
			tr.custom_minimum_size = Vector2(64, 64)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.texture = load("res://art/seasons/paloma/sym_L.png")
			grid.add_child(tr)
			_cells[col].append(tr)
	_win_flash = ColorRect.new()
	_win_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_win_flash.color = Color(1.0, 0.85, 0.4, 0.0)
	_win_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	window.add_child(_win_flash)
	# Chrome bar
	var bar := Panel.new()
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_top = -110
	var bb := StyleBoxFlat.new()
	bb.bg_color = Color(0.18, 0.11, 0.06, 0.92)
	bb.set_border_width_all(2)
	bb.border_color = Color(0.72, 0.52, 0.28)
	bar.add_theme_stylebox_override("panel", bb)
	add_child(bar)
	_credits = Label.new()
	_credits.position = Vector2(40, 18)
	_credits.size = Vector2(400, 36)
	_credits.add_theme_font_size_override("font_size", 24)
	_credits.add_theme_color_override("font_color", Color(0.97, 0.94, 0.88))
	bar.add_child(_credits)
	_result = Label.new()
	_result.position = Vector2(40, 56)
	_result.size = Vector2(500, 32)
	_result.add_theme_font_size_override("font_size", 20)
	_result.add_theme_color_override("font_color", Color(0.95, 0.75, 0.4))
	bar.add_child(_result)
	var odds := Label.new()
	odds.position = Vector2(520, 22)
	odds.size = Vector2(420, 28)
	odds.text = "20 lines · for fun"
	odds.add_theme_font_size_override("font_size", 16)
	odds.add_theme_color_override("font_color", Color(0.85, 0.78, 0.65))
	bar.add_child(odds)
	_style_btn(bar, Vector2(980, 28), Vector2(72, 52), "1", func() -> void: bet = 1; _hud())
	_style_btn(bar, Vector2(1060, 28), Vector2(72, 52), "5", func() -> void: bet = 5; _hud())
	_style_btn(bar, Vector2(1140, 28), Vector2(72, 52), "25", func() -> void: bet = 25; _hud())
	_style_btn(bar, Vector2(1220, 28), Vector2(72, 52), "50", func() -> void: bet = 50; _hud())
	_style_btn(bar, Vector2(1340, 18), Vector2(220, 72), "SPIN", _spin, true)
	_style_btn(bar, Vector2(1600, 28), Vector2(140, 52), "Stand", _stand)
	var title := Label.new()
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_top = 8
	title.offset_bottom = 48
	title.offset_left = -300
	title.offset_right = 300
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = "PALM REELS"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.97, 0.94, 0.88))
	title.add_theme_color_override("font_outline_color", Color(0.1, 0.08, 0.05))
	title.add_theme_constant_override("outline_size", 6)
	add_child(title)


func _style_btn(parent: Node, pos: Vector2, sz: Vector2, text: String, cb: Callable, primary: bool = false) -> void:
	var b := Button.new()
	b.position = pos
	b.size = sz
	b.text = text
	b.pressed.connect(cb)
	var sb := StyleBoxFlat.new()
	if primary:
		sb.bg_color = Color(0.85, 0.55, 0.22)
		sb.set_corner_radius_all(12)
		b.add_theme_font_size_override("font_size", 28)
	else:
		sb.bg_color = Color(0.32, 0.2, 0.1)
		sb.set_corner_radius_all(8)
		b.add_theme_font_size_override("font_size", 18)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.75, 0.55, 0.3)
	b.add_theme_stylebox_override("normal", sb)
	var sbh := sb.duplicate()
	sbh.bg_color = sb.bg_color.lightened(0.12)
	b.add_theme_stylebox_override("hover", sbh)
	b.add_theme_stylebox_override("pressed", sbh)
	b.add_theme_color_override("font_color", Color(0.97, 0.94, 0.88))
	parent.add_child(b)


func _hud() -> void:
	_credits.text = "Credits  %d     Bet  %d" % [Economy.hud_amount(), bet]


func _spin() -> void:
	if spinning:
		return
	if not PlaySafe.chance_staking_allowed():
		Game.toast(Game.text("cool_off_on"))
		return
	if not Game.can_spin_or_deal():
		Game.toast(Game.text("daylight_returns"))
		return
	if not Economy.spend_shells(bet):
		_result.text = "Not enough credits"
		return
	Economy.record_spin(0)
	spinning = true
	Game.play_sfx("click")
	last = PalmReels.play(bet)
	for _i in 14:
		_scramble()
		await get_tree().create_timer(0.045).timeout
	_show_window(last.get("first", {}).get("window", []))
	var total: int = int(last.get("total", 0))
	if total > 0:
		Economy.add_shells(total)
	_result.text = "+%d    net %d" % [total, int(last.get("net", 0))]
	if bool(last.get("celebrate", false)):
		Game.play_sfx("win")
		_flash_win()
	_hud()
	Save.write_disk()
	spinning = false


func _flash_win() -> void:
	var tw := create_tween()
	tw.tween_property(_win_flash, "color:a", 0.35, 0.12)
	tw.tween_property(_win_flash, "color:a", 0.0, 0.35)


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


func _stand() -> void:
	Economy.exit_table_room()
	Save.write_disk()
	Game.goto("casino_floor")
