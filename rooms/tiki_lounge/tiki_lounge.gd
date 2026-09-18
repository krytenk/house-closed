extends Node3D
## Boutique dusk lounge. Tiki-head cabinets with a real reel window.

var bet: int = 1
var last: Dictionary = {}
var spinning: bool = false
var _mode: String = "palm"
var _cells: Array = []
var _overlay: CanvasLayer
var _credits: Label
var _result: Label
var _name: Label
var _odds: Label
var _grid: GridContainer
var _shot_path: String = ""
var _shot_frames: int = 0


func _ready() -> void:
	_build_room()
	_build_overlay()
	_hud()
	_shot_path = OS.get_environment("PALM_SHOT")


func _build_room() -> void:
	RenderingServer.set_default_clear_color(Color(0.05, 0.07, 0.1))
	# Floor
	IslandKit.box(self, Vector3(16, 0.2, 12), Vector3(0, -0.1, 0), Color("#3A2A1C"))
	# Open ocean wall
	IslandKit.box(self, Vector3(16, 6, 0.2), Vector3(0, 3, -6.2), Color("#0B1A2A"))
	var moon := IslandKit.sphere(self, 0.55, Vector3(3.5, 5.2, -5.8), Color("#F7F1E3"))
	moon.material_override = IslandKit.mat(Color("#F7F1E3"), 0.2)
	(moon.material_override as StandardMaterial3D).emission_enabled = true
	(moon.material_override as StandardMaterial3D).emission = Color("#F7F1E3")
	(moon.material_override as StandardMaterial3D).emission_energy_multiplier = 1.4
	# Ocean strip
	IslandKit.box(self, Vector3(16, 0.4, 4), Vector3(0, 0.1, -8.2), Color("#0B6E6F"))
	# Thatch roof
	IslandKit.box(self, Vector3(16.4, 0.25, 12.4), Vector3(0, 4.4, 0), Color("#C4A35A"))
	# Posts
	for x in [-7.2, 7.2]:
		for z in [-4.5, 4.5]:
			IslandKit.cyl(self, 0.16, 0.18, 4.4, Vector3(x, 2.1, z), Color("#6B4F2A"), 8)
	# Bar
	IslandKit.box(self, Vector3(8, 1.1, 0.8), Vector3(0, 0.7, 3.6), Color("#6B3F24"))
	IslandKit.box(self, Vector3(8, 0.12, 1.1), Vector3(0, 1.28, 3.6), Color("#C4A35A"))
	# Stools
	for i in 4:
		IslandKit.cyl(self, 0.22, 0.18, 0.7, Vector3(-2.4 + float(i) * 1.6, 0.45, 2.5), Color("#C4A35A"), 10)
	# Two tiki cabinets facing the player
	IslandKit.add_tiki_cabinet(self, Vector3(-1.6, 0, -1.2), 0.0)
	IslandKit.add_tiki_cabinet(self, Vector3(1.6, 0, -1.2), 0.0)
	# Empty plinth
	IslandKit.box(self, Vector3(1.0, 0.4, 0.7), Vector3(4.2, 0.2, -1.2), Color("#6B3F24"))
	var coming := Label3D.new()
	coming.text = "Coming with the next tide"
	coming.font_size = 28
	coming.position = Vector3(4.2, 1.1, -1.2)
	coming.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	coming.modulate = Color("#F7F1E3")
	add_child(coming)
	# Camera — dusk interior 35mm
	var cam := Camera3D.new()
	cam.fov = 42.0
	cam.position = Vector3(0, 1.55, 4.8)
	cam.current = true
	add_child(cam)
	cam.look_at(Vector3(0, 1.35, -1.2))
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 3.2, 0)
	lamp.light_color = Color("#F4A261")
	lamp.light_energy = 3.2
	lamp.omni_range = 12.0
	add_child(lamp)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-20, 160, 0)
	sun.light_color = Color(0.35, 0.45, 0.7)
	sun.light_energy = 0.35
	add_child(sun)
	var plate := Label3D.new()
	plate.text = "SLOTS"
	plate.font_size = 96
	plate.position = Vector3(0, 3.5, -1.0)
	plate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	plate.modulate = Color("#F7F1E3")
	plate.outline_modulate = Color("#1B1B1B")
	plate.outline_size = 8
	add_child(plate)


func _build_overlay() -> void:
	_overlay = CanvasLayer.new()
	add_child(_overlay)
	_name = _lbl(Vector2(0, 16), Vector2(1920, 48), "PALM REELS", 32)
	_odds = _lbl(Vector2(0, 60), Vector2(1920, 32), "20 lines · fruit + pelican", 16)
	_credits = _lbl(Vector2(0, 92), Vector2(1920, 32), "", 20)
	_result = _lbl(Vector2(0, 980), Vector2(1920, 40), "", 22)
	_grid = GridContainer.new()
	_grid.columns = 5
	_grid.position = Vector2(710, 430)
	_overlay.add_child(_grid)
	_cells = [[], [], [], [], []]
	for row in 3:
		for col in 5:
			var tr := TextureRect.new()
			tr.custom_minimum_size = Vector2(88, 88)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.texture = load("res://art/seasons/paloma/sym_L.png")
			_grid.add_child(tr)
			_cells[col].append(tr)
	_btn(Vector2(860, 760), Vector2(200, 64), "Spin", _spin)
	_btn(Vector2(24, 1000), Vector2(160, 52), "Back", func() -> void: Game.leave_chance_room())
	_btn(Vector2(700, 840), Vector2(80, 48), "1", func() -> void: bet = 1; _hud())
	_btn(Vector2(790, 840), Vector2(80, 48), "5", func() -> void: bet = 5; _hud())
	_btn(Vector2(880, 840), Vector2(80, 48), "25", func() -> void: bet = 25; _hud())
	_btn(Vector2(970, 840), Vector2(80, 48), "50", func() -> void: bet = 50; _hud())
	_btn(Vector2(1600, 1000), Vector2(200, 52), "Wheel", func() -> void: _mode = "wheel"; _name.text = "COCONUT WHEEL"; _odds.text = "16 slices · 5 Shells"; _hud())
	_btn(Vector2(1380, 1000), Vector2(200, 52), "Dive", func() -> void: _mode = "dive"; _name.text = "LAGOON DIVE"; _odds.text = "Clusters of 5"; _hud())
	_btn(Vector2(1160, 1000), Vector2(200, 52), "Reels", func() -> void: _mode = "palm"; _name.text = "PALM REELS"; _odds.text = "20 lines · fruit + pelican"; _hud())


func _lbl(pos: Vector2, sz: Vector2, text: String, size: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = sz
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("#F7F1E3"))
	l.add_theme_color_override("font_outline_color", Color("#1B1B1B"))
	l.add_theme_constant_override("outline_size", 5)
	_overlay.add_child(l)
	return l


func _btn(pos: Vector2, sz: Vector2, text: String, cb: Callable) -> void:
	var b := Button.new()
	b.position = pos
	b.size = sz
	b.text = text
	b.pressed.connect(cb)
	_overlay.add_child(b)


func _process(_delta: float) -> void:
	if _shot_path == "":
		return
	_shot_frames += 1
	if _shot_frames == 18:
		var img: Image = get_viewport().get_texture().get_image()
		img.save_png(_shot_path)
		print("PALM_SHOT ", _shot_path)
		get_tree().quit()


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
