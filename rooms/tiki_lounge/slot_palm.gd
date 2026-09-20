extends Node3D
## First-person sit at a purpose-built 3D cabinet face. Orientation is explicit.

const SYM_ORDER := ["P", "C", "H", "S", "L", "W", "B"]

var bet: int = 1
var spinning: bool = false
var last: Dictionary = {}
var _cells: Array = []
var _credits: Label
var _result: Label
var _bet_label: Label
var _win_flash: ColorRect
var _face: Node3D


func _ready() -> void:
	_build_room()
	_build_face()
	_build_reels()
	_build_hud()
	Economy.enter_table_room()
	_hud()
	_scramble_once()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _mat(color: Color, rough: float = 0.42, emit: Color = Color(0, 0, 0, 0), emit_e: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	if emit_e > 0.0:
		m.emission_enabled = true
		m.emission = emit
		m.emission_energy_multiplier = emit_e
	return m


func _box(parent: Node, size: Vector3, pos: Vector3, mat: Material, name: String = "Box") -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat
	mi.name = name
	parent.add_child(mi)
	return mi


func _cyl(parent: Node, r: float, h: float, pos: Vector3, mat: Material, name: String = "Cyl") -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = r
	mesh.bottom_radius = r
	mesh.height = h
	mesh.radial_segments = 24
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat
	mi.name = name
	parent.add_child(mi)
	return mi


func _sphere(parent: Node, r: float, pos: Vector3, mat: Material, name: String = "Sph") -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = r
	mesh.height = r * 2.0
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat
	mi.name = name
	parent.add_child(mi)
	return mi


func _build_room() -> void:
	RenderingServer.set_default_clear_color(Color(0.03, 0.025, 0.02))
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.04, 0.03, 0.025)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.25, 0.18, 0.12)
	e.ambient_light_energy = 0.4
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.glow_enabled = true
	e.glow_intensity = 0.4
	env.environment = e
	add_child(env)
	# Dim walls so the cabinet is the hero
	_box(self, Vector3(6, 3.2, 0.2), Vector3(0, 1.5, -2.4), _mat(Color(0.08, 0.05, 0.03)), "BackWall")
	_box(self, Vector3(0.2, 3.2, 4), Vector3(-2.6, 1.5, -0.5), _mat(Color(0.07, 0.04, 0.025)), "WallL")
	_box(self, Vector3(0.2, 3.2, 4), Vector3(2.6, 1.5, -0.5), _mat(Color(0.07, 0.04, 0.025)), "WallR")
	_box(self, Vector3(6, 0.15, 4), Vector3(0, 0, -0.5), _mat(Color(0.12, 0.07, 0.04), 0.6), "Floor")


func _build_face() -> void:
	_face = Node3D.new()
	_face.name = "CabinetFace"
	_face.position = Vector3(0, 0, -1.35)
	add_child(_face)
	var wood := _mat(Color(0.4, 0.2, 0.09), 0.36)
	var dark := _mat(Color(0.12, 0.06, 0.03), 0.5)
	var amber := _mat(Color(0.95, 0.55, 0.15), 0.3, Color(0.95, 0.45, 0.1), 2.2)
	var cream := _mat(Color(0.9, 0.82, 0.65), 0.55)
	# Body
	_box(_face, Vector3(1.15, 1.7, 0.85), Vector3(0, 1.0, 0), wood, "Body")
	_box(_face, Vector3(1.28, 0.2, 0.95), Vector3(0, 0.12, 0), dark, "Base")
	_cyl(_face, 0.07, 0.25, Vector3(-0.4, 0.12, 0.28), dark, "LegFL")
	_cyl(_face, 0.07, 0.25, Vector3(0.4, 0.12, 0.28), dark, "LegFR")
	_cyl(_face, 0.07, 0.25, Vector3(-0.4, 0.12, -0.28), dark, "LegBL")
	_cyl(_face, 0.07, 0.25, Vector3(0.4, 0.12, -0.28), dark, "LegBR")
	# Head
	_cyl(_face, 0.48, 0.58, Vector3(0, 2.05, 0), wood, "Head")
	_box(_face, Vector3(0.78, 0.12, 0.22), Vector3(0, 2.22, 0.32), dark, "Brow")
	_sphere(_face, 0.09, Vector3(-0.16, 2.08, 0.4), amber, "EyeL")
	_sphere(_face, 0.09, Vector3(0.16, 2.08, 0.4), amber, "EyeR")
	_box(_face, Vector3(0.38, 0.09, 0.14), Vector3(0, 1.9, 0.4), dark, "Mouth")
	_box(_face, Vector3(0.18, 0.38, 0.22), Vector3(0, 2.45, 0), cream, "Crest")
	# Reel frame (front)
	_box(_face, Vector3(0.92, 0.12, 0.08), Vector3(0, 1.48, 0.44), dark, "FrameTop")
	_box(_face, Vector3(0.92, 0.12, 0.08), Vector3(0, 0.72, 0.44), dark, "FrameBot")
	_box(_face, Vector3(0.1, 0.64, 0.08), Vector3(-0.42, 1.1, 0.44), dark, "FrameL")
	_box(_face, Vector3(0.1, 0.64, 0.08), Vector3(0.42, 1.1, 0.44), dark, "FrameR")
	# Recess
	_box(_face, Vector3(0.78, 0.58, 0.06), Vector3(0, 1.1, 0.38), _mat(Color(0.015, 0.015, 0.02)), "Recess")
	# Belly plate
	_box(_face, Vector3(0.75, 0.42, 0.06), Vector3(0, 0.42, 0.44), dark, "Belly")
	_box(_face, Vector3(0.5, 0.08, 0.16), Vector3(0, 0.55, 0.5), _mat(Color(0.08, 0.08, 0.08), 0.3), "Buttons")

	var cam := Camera3D.new()
	cam.name = "SitCam"
	cam.fov = 38.0
	cam.position = Vector3(0, 1.25, 0.55)
	cam.current = true
	add_child(cam)
	cam.look_at(Vector3(0, 1.35, -1.0), Vector3.UP)

	var key := SpotLight3D.new()
	key.light_color = Color(1.0, 0.82, 0.55)
	key.light_energy = 12.0
	key.spot_range = 7.0
	key.spot_angle = 40.0
	add_child(key)
	key.position = Vector3(0.4, 1.9, 0.9)
	key.look_at(Vector3(0, 1.4, -1.2), Vector3.UP)

	var fill := OmniLight3D.new()
	fill.position = Vector3(-0.7, 1.3, 0.6)
	fill.light_color = Color(0.4, 0.5, 0.7)
	fill.light_energy = 1.5
	fill.omni_range = 5.0
	add_child(fill)

	var rim := OmniLight3D.new()
	rim.position = Vector3(0, 2.4, -1.6)
	rim.light_color = Color(1.0, 0.5, 0.2)
	rim.light_energy = 2.2
	rim.omni_range = 4.0
	add_child(rim)


func _build_reels() -> void:
	_cells.clear()
	var anchor := Node3D.new()
	anchor.name = "ReelWindow"
	anchor.position = Vector3(0, 1.1, -0.92)
	add_child(anchor)
	for col in 5:
		var col_cells: Array = []
		for row in 3:
			var mi := MeshInstance3D.new()
			var quad := QuadMesh.new()
			quad.size = Vector2(0.13, 0.15)
			mi.mesh = quad
			mi.position = Vector3(-0.26 + float(col) * 0.13, 0.17 - float(row) * 0.16, 0.0)
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
