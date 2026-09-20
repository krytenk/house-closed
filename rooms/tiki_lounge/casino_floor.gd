extends Node3D
## Casino floor — bank of slots. Click a machine to sit.

const FLOOR_TEX := "res://art/seasons/paloma/refs/image-498ab62c-b49d-4719-8efa-0b0af2992a8d.jpg"
const CAB_PALM := "res://art/seasons/paloma/cabinet_palm.jpg"
const CAB_WHEEL := "res://art/seasons/paloma/cabinet_wheel.jpg"
const CAB_DIVE := "res://art/seasons/paloma/cabinet_dive.jpg"

var _cam: Camera3D
var _yaw: float = 0.0
var _pitch: float = 0.0
var _dragging: bool = false
var _entering: bool = false
var _machines: Array = []
var _hint: Label
var _shot_path: String = ""
var _shot_frames: int = 0


func _ready() -> void:
	_build()
	_shot_path = OS.get_environment("PALM_SHOT")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_process(true)


func _process(_delta: float) -> void:
	if _shot_path != "":
		_shot_frames += 1
		if _shot_frames == 18:
			get_viewport().get_texture().get_image().save_png(_shot_path)
			print("PALM_SHOT ", _shot_path)
			get_tree().quit()
			return
	if _entering:
		return
	for i in _machines.size():
		var g: MeshInstance3D = (_machines[i] as Dictionary)["glow"]
		var m: StandardMaterial3D = g.material_override
		var pulse: float = 0.15 + 0.1 * sin(Time.get_ticks_msec() / 450.0 + float(i))
		m.albedo_color.a = pulse
		m.emission_energy_multiplier = 0.6 + pulse


func _unhandled_input(event: InputEvent) -> void:
	if _entering:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = mb.pressed
		elif mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			var vp := get_viewport().get_visible_rect().size
			# Lower-middle band over the three cabinets
			if mb.position.y > vp.y * 0.28 and mb.position.y < vp.y * 0.88:
				var frac: float = mb.position.x / vp.x
				if frac > 0.12 and frac < 0.36:
					_sit(0)
				elif frac > 0.38 and frac < 0.62:
					_sit(1)
				elif frac > 0.64 and frac < 0.88:
					_sit(2)
	if event is InputEventMouseMotion and _dragging:
		var mm := event as InputEventMouseMotion
		_yaw -= mm.relative.x * 0.003
		_pitch -= mm.relative.y * 0.0025
		_yaw = clampf(_yaw, -0.7, 0.7)
		_pitch = clampf(_pitch, -0.3, 0.3)
		_cam.rotation = Vector3(_pitch, _yaw, 0.0)
	if event.is_action_pressed("ui_cancel"):
		Game.goto("lobby")


func _build() -> void:
	RenderingServer.set_default_clear_color(Color(0.04, 0.05, 0.07))
	var plate := MeshInstance3D.new()
	var pm := QuadMesh.new()
	pm.size = Vector2(19.2, 10.8)
	plate.mesh = pm
	plate.position = Vector3(0, 1.55, -5.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load(FLOOR_TEX)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	plate.material_override = mat
	add_child(plate)
	var floor := MeshInstance3D.new()
	var fm := PlaneMesh.new()
	fm.size = Vector2(14, 10)
	floor.mesh = fm
	var fm_mat := StandardMaterial3D.new()
	fm_mat.albedo_color = Color(0.12, 0.09, 0.07)
	floor.material_override = fm_mat
	add_child(floor)
	_machines = []
	var cabs := [
		{"tex": CAB_PALM, "x": -2.35},
		{"tex": CAB_WHEEL, "x": 0.0},
		{"tex": CAB_DIVE, "x": 2.35},
	]
	for i in cabs.size():
		var c: Dictionary = cabs[i]
		var cab := MeshInstance3D.new()
		var qm := QuadMesh.new()
		qm.size = Vector2(1.85, 2.85)
		cab.mesh = qm
		cab.position = Vector3(float(c["x"]), 1.4, -1.85)
		var cm := StandardMaterial3D.new()
		cm.albedo_texture = load(str(c["tex"]))
		cm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		cm.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
		cab.material_override = cm
		add_child(cab)
		var glow := MeshInstance3D.new()
		var gq := QuadMesh.new()
		gq.size = Vector2(2.05, 3.05)
		glow.mesh = gq
		glow.position = Vector3(float(c["x"]), 1.4, -1.82)
		var gm := StandardMaterial3D.new()
		gm.albedo_color = Color(1.0, 0.75, 0.35, 0.2)
		gm.emission_enabled = true
		gm.emission = Color(1.0, 0.7, 0.3)
		gm.emission_energy_multiplier = 1.0
		gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		gm.cull_mode = BaseMaterial3D.CULL_DISABLED
		glow.material_override = gm
		add_child(glow)
		_machines.append({"cab": cab, "glow": glow, "x": float(c["x"])})
	_cam = Camera3D.new()
	_cam.fov = 52.0
	_cam.position = Vector3(0, 1.55, 2.6)
	_cam.current = true
	add_child(_cam)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 2.6, 0)
	lamp.light_color = Color(1.0, 0.7, 0.4)
	lamp.light_energy = 2.8
	lamp.omni_range = 12.0
	add_child(lamp)
	var layer := CanvasLayer.new()
	layer.layer = 12
	add_child(layer)
	# Three invisible machine hotspots across the lower-middle of the screen
	for i in 3:
		var hs := Button.new()
		hs.name = "MachineHotspot_%d" % i
		hs.flat = true
		hs.focus_mode = Control.FOCUS_NONE
		hs.modulate = Color(1, 1, 1, 0.01)
		hs.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		hs.offset_top = -720
		hs.offset_bottom = -160
		var left_frac: float = 0.12 + float(i) * 0.26
		hs.anchor_left = left_frac
		hs.anchor_right = left_frac + 0.24
		hs.offset_left = 0
		hs.offset_right = 0
		var idx: int = i
		hs.pressed.connect(func() -> void: _sit(idx))
		hs.mouse_entered.connect(func() -> void: _hint.text = "Sit at this machine")
		hs.mouse_exited.connect(func() -> void: _hint.text = "Click a glowing machine to sit")
		layer.add_child(hs)
	_hint = Label.new()
	_hint.name = "Hint"
	_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hint.offset_top = -64
	_hint.offset_bottom = -24
	_hint.offset_left = -480
	_hint.offset_right = 480
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 18)
	_hint.add_theme_color_override("font_color", Color(0.97, 0.94, 0.88, 0.9))
	_hint.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.05))
	_hint.add_theme_constant_override("outline_size", 5)
	_hint.text = "Click a glowing machine to sit · Esc returns to lobby"
	layer.add_child(_hint)
	var back := TextureButton.new()
	back.name = "BackBtn"
	back.texture_normal = load("res://art/seasons/paloma/btn_house.png")
	back.ignore_texture_size = true
	back.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	back.custom_minimum_size = Vector2(56, 56)
	back.position = Vector2(24, 24)
	back.pressed.connect(func() -> void: Game.goto("lobby"))
	layer.add_child(back)


func _sit(idx: int) -> void:
	if _entering or idx < 0 or idx >= _machines.size():
		return
	if not PlaySafe.chance_staking_allowed():
		Game.toast(Game.text("cool_off_on"))
		return
	_entering = true
	_hint.text = ""
	var mx: float = float((_machines[idx] as Dictionary)["x"])
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_cam, "position", Vector3(mx, 1.4, -0.35), 0.7)
	tw.parallel().tween_property(_cam, "rotation", Vector3(0.04, 0.0, 0.0), 0.7)
	tw.tween_callback(func() -> void: Game.enter_chance_room("slot_palm"))
