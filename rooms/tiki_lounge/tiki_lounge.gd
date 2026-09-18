extends Control

var bet: int = 1
var last: Dictionary = {}
var spinning: bool = false
var _cells: Array = []
var _mode: String = "room"


func _ready() -> void:
	$Plate.text = Game.text("door_slots_plate")
	$FunOnly.text = Game.text("fun_only")
	$Coming.text = Game.text("coming_next_tide")
	$Back.pressed.connect(_back)
	$Palm.pressed.connect(func() -> void: _open_cabinet("palm"))
	$Wheel.pressed.connect(func() -> void: _open_cabinet("wheel"))
	$Dive.pressed.connect(func() -> void: _open_cabinet("dive"))
	$Closeup/Spin.pressed.connect(_spin)
	$Closeup/Bet1.pressed.connect(func() -> void: bet = 1; _hud())
	$Closeup/Bet5.pressed.connect(func() -> void: bet = 5; _hud())
	$Closeup/Bet25.pressed.connect(func() -> void: bet = 25; _hud())
	$Closeup/Bet50.pressed.connect(func() -> void: bet = 50; _hud())
	$Closeup.visible = false
	_build_grid()
	_hud()
	var shot: String = OS.get_environment("PALM_SHOT")
	if shot != "":
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(shot)
		print("PALM_SHOT ", shot)
		get_tree().quit()


func _build_grid() -> void:
	_cells.clear()
	var grid: GridContainer = $Closeup/Grid
	for c in grid.get_children():
		c.queue_free()
	grid.columns = 5
	_cells = [[], [], [], [], []]
	for row in 3:
		for col in 5:
			var tr := TextureRect.new()
			tr.custom_minimum_size = Vector2(96, 96)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.texture = load("res://art/seasons/paloma/sym_L.png")
			grid.add_child(tr)
			_cells[col].append(tr)


func _open_cabinet(mode: String) -> void:
	_mode = mode
	$Closeup.visible = true
	$Room.visible = false
	$Palm.visible = false
	$Wheel.visible = false
	$Dive.visible = false
	$Coming.visible = false
	$Plate.visible = false
	match mode:
		"palm":
			$Closeup/Name.text = "PALM REELS"
			$Closeup/Odds.text = "20 lines · fruit + pelican · 96.0%"
		"wheel":
			$Closeup/Name.text = "COCONUT WHEEL"
			$Closeup/Odds.text = "16 slices · 5 Shells · 95.5%"
		"dive":
			$Closeup/Name.text = "LAGOON DIVE"
			$Closeup/Odds.text = "Clusters of 5 · 96.2%"
	_hud()


func _back() -> void:
	if $Closeup.visible:
		$Closeup.visible = false
		$Room.visible = true
		$Palm.visible = true
		$Wheel.visible = true
		$Dive.visible = true
		$Coming.visible = true
		$Plate.visible = true
		return
	Game.leave_chance_room()


func _hud() -> void:
	$Closeup/Credits.text = "%d   bet %d" % [Economy.hud_amount(), bet]


func _spin() -> void:
	if spinning:
		return
	var cost: int = CoconutWheel.COST if _mode == "wheel" else bet
	if not _stake(cost):
		return
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
	_pay(last)
	spinning = false


func _scramble() -> void:
	var keys := ["P", "C", "H", "S", "L", "W", "B"]
	for col in _cells:
		for cell in col:
			var k: String = keys[randi() % keys.size()]
			(cell as TextureRect).texture = _tex(k)


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


func _stake(n: int) -> bool:
	if not PlaySafe.chance_staking_allowed():
		Game.toast(Game.text("cool_off_on"))
		return false
	if not Game.can_spin_or_deal():
		Game.toast(Game.text("daylight_returns"))
		return false
	if not Economy.spend_shells(n):
		$Closeup/Result.text = "Not enough"
		return false
	Economy.record_spin(0)
	return true


func _pay(result: Dictionary) -> void:
	var total: int = int(result.get("total", 0))
	if total > 0:
		Economy.add_shells(total)
	$Closeup/Result.text = "+%d   net %d" % [total, int(result.get("net", 0))]
	if bool(result.get("celebrate", false)):
		Game.play_sfx("win")
	_hud()
	Save.write_disk()
