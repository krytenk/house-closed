extends Node3D
## First-person sit — same CabinetBuilder face as the floor, close and playable.

const CabinetBuilderScript := preload("res://rooms/tiki_lounge/cabinet_builder.gd")
const SYM_ORDER := ["P", "C", "H", "S", "L", "W", "B"]

var bet: int = 1
var spinning: bool = false
var last: Dictionary = {}
var _cab: Node3D
var _cells: Array = []
var _credits: Label
var _result: Label
var _bet_label: Label
var _win_flash: ColorRect


func _ready() -> void:
	_build_room()
	_cab = CabinetBuilderScript.build(self, Vector3(0, 0, -1.35), 1.25, false)
	_cab.name = "Cabinet"
	_build_reels()
	_build_camera_lights()
	_build_hud()
	Economy.enter_table_room()
	_hud()
	_scramble_once()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _build_room() -> void:
	RenderingServer.set_default_clear_color(Color(0.03, 0.025, 0.02))
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.04, 0.03, 0.025)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.32, 0.24, 0.18)
	e.ambient_light_energy = 0.7
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.glow_enabled = true
	e.glow_intensity = 0.4
	env.environment = e
	add_child(env)
	CabinetBuilderScript.box(self, Vector3(6, 3.2, 0.2), Vector3(0, 1.5, -2.5), CabinetBuilderScript.mat(Color(0.08, 0.05, 0.03)), "BackWall")
	CabinetBuilderScript.box(self, Vector3(0.2, 3.2, 4), Vector3(-2.8, 1.5, -0.5), CabinetBuilderScript.mat(Color(0.07, 0.04, 0.025)), "WallL")
	CabinetBuilderScript.box(self, Vector3(0.2, 3.2, 4), Vector3(2.8, 1.5, -0.5), CabinetBuilderScript.mat(Color(0.07, 0.04, 0.025)), "WallR")
	CabinetBuilderScript.box(self, Vector3(6, 0.15, 4), Vector3(0, 0, -0.5), CabinetBuilderScript.mat(Color(0.12, 0.07, 0.04), 0.6), "Floor")


func _build_camera_lights() -> void:
	var rw: Node3D = _cab.find_child("ReelWindow", true, false) as Node3D
	var focus := Vector3(0, 1.35, -0.9)
	if rw:
		focus = rw.global_position
	var cam := Camera3D.new()
	cam.name = "SitCam"
	cam.fov = 50.0
	cam.current = true
	add_child(cam)
	cam.global_position = focus + Vector3(0, -0.28, 2.5)
	cam.look_at(focus + Vector3(0, 0.35, 0), Vector3.UP)
	var key := SpotLight3D.new()
	key.light_color = Color(1.0, 0.86, 0.62)
	key.light_energy = 4.5
	key.spot_range = 7.0
	key.spot_angle = 38.0
	add_child(key)
	key.global_position = focus + Vector3(0.55, 0.7, 1.4)
	key.look_at(focus, Vector3.UP)
	var fill := OmniLight3D.new()
	fill.light_color = Color(0.4, 0.5, 0.7)
	fill.light_energy = 0.9
	fill.omni_range = 5.0
	add_child(fill)
	fill.global_position = focus + Vector3(-0.8, 0.2, 1.0)
	var rim := OmniLight3D.new()
	rim.light_color = Color(1.0, 0.55, 0.25)
	rim.light_energy = 1.2
	rim.omni_range = 4.0
	add_child(rim)
	rim.global_position = focus + Vector3(0, 0.9, -0.4)


func _build_reels() -> void:
	_cells.clear()
	var anchor: Node3D = _cab.find_child("ReelWindow", true, false) as Node3D
	if anchor == null:
		anchor = Node3D.new()
		anchor.name = "ReelWindow"
		anchor.position = Vector3(0, 1.1, 0.45)
		_cab.add_child(anchor)
	for col in 5:
		var col_cells: Array = []
		for row in 3:
			var mi := MeshInstance3D.new()
			var quad := QuadMesh.new()
			quad.size = Vector2(0.13, 0.15)
			mi.mesh = quad
			mi.position = Vector3(-0.26 + float(col) * 0.13, 0.16 - float(row) * 0.16, 0.0)
			var mat := StandardMaterial3D.new()
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mat.albedo_texture = _tex("L")
			mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
			mi.material_override = mat
			mi.name = "Cell_%d_%d" % [col, row]
			anchor.add_child(mi)
			col_cells.append(mi)
		_cells.append(col_cells)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)
	var bar := Panel.new()
	bar.name = "Bar"
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_top = -88
	bar.offset_left = 180
	bar.offset_right = -180
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.06, 0.03, 0.9)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.72, 0.5, 0.28)
	sb.set_corner_radius_all(10)
	bar.add_theme_stylebox_override("panel", sb)
	layer.add_child(bar)
	_credits = Label.new()
	_credits.position = Vector2(24, 12)
	_credits.size = Vector2(360, 28)
	_credits.add_theme_font_size_override("font_size", 20)
	_credits.add_theme_color_override("font_color", Color(0.97, 0.94, 0.88))
	bar.add_child(_credits)
	_bet_label = Label.new()
	_bet_label.position = Vector2(24, 42)
	_bet_label.size = Vector2(200, 24)
	_bet_label.add_theme_font_size_override("font_size", 16)
	_bet_label.add_theme_color_override("font_color", Color(0.85, 0.75, 0.55))
	bar.add_child(_bet_label)
	_result = Label.new()
	_result.position = Vector2(220, 42)
	_result.size = Vector2(320, 24)
	_result.add_theme_font_size_override("font_size", 16)
	_result.add_theme_color_override("font_color", Color(0.95, 0.75, 0.4))
	bar.add_child(_result)
	_mk_btn(bar, Vector2(560, 18), Vector2(56, 48), "1", func() -> void: bet = 1; _hud())
	_mk_btn(bar, Vector2(624, 18), Vector2(56, 48), "5", func() -> void: bet = 5; _hud())
	_mk_btn(bar, Vector2(688, 18), Vector2(56, 48), "25", func() -> void: bet = 25; _hud())
	_mk_btn(bar, Vector2(752, 18), Vector2(56, 48), "50", func() -> void: bet = 50; _hud())
	var spin := _mk_btn(bar, Vector2(840, 10), Vector2(180, 64), "SPIN", _spin, true)
	spin.name = "SpinBtn"
	var stand := _mk_btn(bar, Vector2(1040, 18), Vector2(120, 48), "Stand", _stand)
	stand.name = "StandBtn"
	_win_flash = ColorRect.new()
	_win_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_win_flash.color = Color(1, 0.85, 0.4, 0)
	_win_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_win_flash)


func _mk_btn(parent: Node, pos: Vector2, sz: Vector2, text: String, cb: Callable, primary: bool = false) -> Button:
	var b := Button.new()
	b.position = pos
	b.size = sz
	b.text = text
	b.pressed.connect(cb)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.88, 0.55, 0.2) if primary else Color(0.26, 0.15, 0.07)
	sb.set_corner_radius_all(10 if primary else 8)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.78, 0.55, 0.28)
	b.add_theme_stylebox_override("normal", sb)
	var h := sb.duplicate()
	h.bg_color = sb.bg_color.lightened(0.14)
	b.add_theme_stylebox_override("hover", h)
	b.add_theme_stylebox_override("pressed", h)
	b.add_theme_font_size_override("font_size", 26 if primary else 18)
	b.add_theme_color_override("font_color", Color(0.97, 0.94, 0.88))
	parent.add_child(b)
	return b


func _hud() -> void:
	_credits.text = "Credits  %d" % Economy.hud_amount()
	_bet_label.text = "Bet  %d" % bet


func _tex(sym: String) -> Texture2D:
	var path := "res://art/seasons/paloma/sym_%s.png" % sym
	if ResourceLoader.exists(path):
		return load(path)
	return load("res://art/seasons/paloma/sym_L.png")


func _set_cell(col: int, row: int, sym: String) -> void:
	var mi: MeshInstance3D = _cells[col][row]
	var mat: StandardMaterial3D = mi.material_override
	mat.albedo_texture = _tex(sym)


func _scramble_once() -> void:
	for col in 5:
		for row in 3:
			_set_cell(col, row, SYM_ORDER[randi() % SYM_ORDER.size()])


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
	for _tick in 18:
		_scramble_once()
		await get_tree().create_timer(0.035).timeout
	var window: Array = last.get("first", {}).get("window", [])
	for col in 5:
		if window.size() > col:
			var col_syms: Array = window[col]
			for row in mini(3, col_syms.size()):
				_set_cell(col, row, str(col_syms[row]))
		await get_tree().create_timer(0.05).timeout
	var total: int = int(last.get("total", 0))
	if total > 0:
		Economy.add_shells(total)
	_result.text = "+%d   net %d" % [total, int(last.get("net", 0))]
	if bool(last.get("celebrate", false)):
		Game.play_sfx("win")
		var tw := create_tween()
		tw.tween_property(_win_flash, "color:a", 0.3, 0.1)
		tw.tween_property(_win_flash, "color:a", 0.0, 0.4)
	_hud()
	Save.write_disk()
	spinning = false


func _stand() -> void:
	Economy.exit_table_room()
	Save.write_disk()
	Game.goto("casino_floor")
