extends Node3D
## First-person sit at a 3D tiki cabinet with real reel cylinders.

const CABINET := "res://art/models/tiki_cabinet.glb"
const STRIP := "res://art/seasons/paloma/reel_strip.png"
const SYM_ORDER := ["P", "C", "H", "S", "L", "W", "B"]

var bet: int = 1
var spinning: bool = false
var last: Dictionary = {}
var _cab: Node3D
var _reels: Array = []  # MeshInstance3D cylinders
var _credits: Label
var _result: Label
var _win_flash: ColorRect


func _ready() -> void:
	_build_cabinet()
	_build_reels()
	_build_hud()
	Economy.enter_table_room()
	_hud()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _build_cabinet() -> void:
	RenderingServer.set_default_clear_color(Color(0.04, 0.03, 0.025))
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.05, 0.04, 0.03)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.3, 0.22, 0.15)
	e.ambient_light_energy = 0.5
	env.environment = e
	add_child(env)
	var ps: PackedScene = load(CABINET)
	_cab = ps.instantiate()
	_cab.name = "Cabinet"
	_cab.position = Vector3(0, 0, 0)
	_cab.scale = Vector3(1.3, 1.3, 1.3)
	_paint(_cab)
	add_child(_cab)
	var rw: Node3D = _cab.find_child("ReelWindow", true, false) as Node3D
	var focus := Vector3(0, 1.25, -0.5)
	if rw:
		focus = rw.global_position
	var cam := Camera3D.new()
	cam.name = "SitCam"
	cam.fov = 40.0
	cam.current = true
	add_child(cam)
	# Stand back from the glass, eye-level with the window
	cam.global_position = focus + Vector3(0, 0.05, 1.15)
	cam.look_at(focus, Vector3.UP)
	var lamp := OmniLight3D.new()
	lamp.position = focus + Vector3(0.5, 0.6, 0.8)
	lamp.light_color = Color(1.0, 0.8, 0.5)
	lamp.light_energy = 5.0
	lamp.omni_range = 7.0
	add_child(lamp)
	var fill := OmniLight3D.new()
	fill.position = focus + Vector3(-0.7, 0.3, 0.9)
	fill.light_color = Color(0.45, 0.55, 0.75)
	fill.light_energy = 1.6
	fill.omni_range = 6.0
	add_child(fill)


func _paint(cab: Node) -> void:
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.34, 0.17, 0.07)
	wood.roughness = 0.4
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.12, 0.06, 0.03)
	dark.roughness = 0.5
	var amber := StandardMaterial3D.new()
	amber.albedo_color = Color(0.95, 0.55, 0.15)
	amber.emission_enabled = true
	amber.emission = Color(0.95, 0.45, 0.1)
	amber.emission_energy_multiplier = 1.4
	for mi in cab.find_children("*", "MeshInstance3D", true, false):
		var mesh_i := mi as MeshInstance3D
		var n: String = mesh_i.name.to_lower()
		if n.find("eye") != -1:
			mesh_i.material_override = amber
		elif n.find("glass") != -1:
			var g := StandardMaterial3D.new()
			g.albedo_color = Color(0.03, 0.03, 0.04, 0.35)
			g.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			g.roughness = 0.05
			mesh_i.material_override = g
		elif n.find("dark") != -1 or n.find("mouth") != -1 or n.find("brow") != -1 or n.find("belly") != -1 or n.find("side") != -1 or n.find("base") != -1 or n.find("leg") != -1 or n.find("frame") != -1:
			mesh_i.material_override = dark
		else:
			mesh_i.material_override = wood


func _build_reels() -> void:
	_reels.clear()
	var anchor: Node3D = _cab.find_child("ReelWindow", true, false) as Node3D
	if anchor == null:
		anchor = Node3D.new()
		anchor.name = "ReelWindow"
		anchor.position = Vector3(0, 1.03, 0.42)
		_cab.add_child(anchor)
	var strip: Texture2D = load(STRIP)
	for i in 5:
		var mi := MeshInstance3D.new()
		var quad := QuadMesh.new()
		quad.size = Vector2(0.12, 0.48)
		mi.mesh = quad
		mi.position = Vector3(-0.26 + float(i) * 0.13, 0.0, 0.04)
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = strip
		mat.uv1_scale = Vector3(1, float(SYM_ORDER.size()), 1)
		mat.uv1_offset = Vector3(0, float(i) * 0.13, 0)
		mat.roughness = 0.35
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mi.material_override = mat
		anchor.add_child(mi)
		_reels.append(mi)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var bar := Panel.new()
	bar.name = "Bar"
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_top = -100
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.07, 0.04, 0.9)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.7, 0.5, 0.28)
	bar.add_theme_stylebox_override("panel", sb)
	layer.add_child(bar)
	_credits = Label.new()
	_credits.position = Vector2(36, 16)
	_credits.size = Vector2(480, 32)
	_credits.add_theme_font_size_override("font_size", 22)
	_credits.add_theme_color_override("font_color", Color(0.97, 0.94, 0.88))
	bar.add_child(_credits)
	_result = Label.new()
	_result.position = Vector2(36, 50)
	_result.size = Vector2(480, 28)
	_result.add_theme_font_size_override("font_size", 18)
	_result.add_theme_color_override("font_color", Color(0.95, 0.75, 0.4))
	bar.add_child(_result)
	_mk_btn(bar, Vector2(900, 22), Vector2(64, 48), "1", func() -> void: bet = 1; _hud())
	_mk_btn(bar, Vector2(972, 22), Vector2(64, 48), "5", func() -> void: bet = 5; _hud())
	_mk_btn(bar, Vector2(1044, 22), Vector2(64, 48), "25", func() -> void: bet = 25; _hud())
	_mk_btn(bar, Vector2(1116, 22), Vector2(64, 48), "50", func() -> void: bet = 50; _hud())
	var spin := _mk_btn(bar, Vector2(1220, 14), Vector2(200, 64), "SPIN", _spin, true)
	spin.name = "SpinBtn"
	var stand := _mk_btn(bar, Vector2(1450, 22), Vector2(140, 48), "Stand", _stand)
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
	sb.bg_color = Color(0.85, 0.55, 0.22) if primary else Color(0.28, 0.16, 0.08)
	sb.set_corner_radius_all(10 if primary else 8)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.75, 0.55, 0.3)
	b.add_theme_stylebox_override("normal", sb)
	var h := sb.duplicate()
	h.bg_color = sb.bg_color.lightened(0.12)
	b.add_theme_stylebox_override("hover", h)
	b.add_theme_stylebox_override("pressed", h)
	b.add_theme_font_size_override("font_size", 26 if primary else 18)
	b.add_theme_color_override("font_color", Color(0.97, 0.94, 0.88))
	parent.add_child(b)
	return b


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
	# Spin cylinders
	for _i in 16:
		for r in _reels:
			var m: StandardMaterial3D = (r as MeshInstance3D).material_override
			m.uv1_offset.y = fmod(m.uv1_offset.y + 0.17, 1.0)
		await get_tree().create_timer(0.04).timeout
	_apply_result_window(last.get("first", {}).get("window", []))
	var total: int = int(last.get("total", 0))
	if total > 0:
		Economy.add_shells(total)
	_result.text = "+%d    net %d" % [total, int(last.get("net", 0))]
	if bool(last.get("celebrate", false)):
		Game.play_sfx("win")
		var tw := create_tween()
		tw.tween_property(_win_flash, "color:a", 0.28, 0.1)
		tw.tween_property(_win_flash, "color:a", 0.0, 0.35)
	_hud()
	Save.write_disk()
	spinning = false


func _apply_result_window(window: Array) -> void:
	# window: 5 columns of 3 symbols — map center row to reel UV
	if window.size() < 5:
		return
	for c in mini(5, _reels.size()):
		var col: Array = window[c]
		var sym: String = str(col[1]) if col.size() > 1 else str(col[0])
		var idx: int = SYM_ORDER.find(sym)
		if idx < 0:
			idx = 0
		var m: StandardMaterial3D = (_reels[c] as MeshInstance3D).material_override
		m.uv1_offset.y = float(idx) / float(SYM_ORDER.size())


func _stand() -> void:
	Economy.exit_table_room()
	Save.write_disk()
	Game.goto("casino_floor")
