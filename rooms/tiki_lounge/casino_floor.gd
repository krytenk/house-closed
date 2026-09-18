extends Node3D
## Casino floor — bank of slots. Walk up and sit at a machine.

const FLOOR_TEX := "res://art/seasons/paloma/refs/image-498ab62c-b49d-4719-8efa-0b0af2992a8d.jpg"
const CAB_PALM := "res://art/seasons/paloma/cabinet_palm.jpg"
const CAB_WHEEL := "res://art/seasons/paloma/cabinet_wheel.jpg"
const CAB_DIVE := "res://art/seasons/paloma/cabinet_dive.jpg"

var _cam: Camera3D
var _yaw: float = 0.0
var _pitch: float = 0.0
var _machines: Array = []
var _hovered: int = -1
var _entering: bool = false
var _hint: Label
var _shot_path: String = ""
var _shot_frames: int = 0


func _ready() -> void:
	_build()
	_shot_path = OS.get_environment("PALM_SHOT")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process(true)


func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(_delta: float) -> void:
	if _shot_path != "":
		_shot_frames += 1
		if _shot_frames == 18:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_viewport().get_texture().get_image().save_png(_shot_path)
			print("PALM_SHOT ", _shot_path)
			get_tree().quit()
			return
	if _entering:
		return
	_update_hover()


func _unhandled_input(event: InputEvent) -> void:
	if _entering:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mm := event as InputEventMouseMotion
		_yaw -= mm.relative.x * 0.0020
		_pitch -= mm.relative.y * 0.0018
		_yaw = clampf(_yaw, -0.7, 0.7)
		_pitch = clampf(_pitch, -0.3, 0.3)
		_apply_look()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_sit()
	if event.is_action_pressed("walk") or event.is_action_pressed("ui_accept"):
		_try_sit()
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Game.goto("lobby")
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _build() -> void:
	RenderingServer.set_default_clear_color(Color(0.04, 0.05, 0.07))
	# Room plate — the bank of slots
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
	# Floor
	var floor := MeshInstance3D.new()
	var fm := PlaneMesh.new()
	fm.size = Vector2(14, 10)
	floor.mesh = fm
	var fm_mat := StandardMaterial3D.new()
	fm_mat.albedo_color = Color(0.12, 0.09, 0.07)
	floor.material_override = fm_mat
	add_child(floor)
	# Physical cabinets in front of the plate — walk up to these
	_machines = []
	var cabs := [
		{"tex": CAB_PALM, "x": -2.4, "scene": "slot_palm"},
		{"tex": CAB_WHEEL, "x": 0.0, "scene": "slot_palm"},
		{"tex": CAB_DIVE, "x": 2.4, "scene": "slot_palm"},
	]
	for i in cabs.size():
		var c: Dictionary = cabs[i]
		var cab := MeshInstance3D.new()
		var qm := QuadMesh.new()
		qm.size = Vector2(1.7, 2.6)
		cab.mesh = qm
		cab.position = Vector3(float(c["x"]), 1.35, -2.15)
		cab.name = "Machine_%d" % i
		var cm := StandardMaterial3D.new()
		cm.albedo_texture = load(str(c["tex"]))
		cm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		cm.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
		cab.material_override = cm
		add_child(cab)
		# Soft selection glow frame
		var glow := MeshInstance3D.new()
		var gq := QuadMesh.new()
		gq.size = Vector2(1.85, 2.75)
		glow.mesh = gq
		glow.position = Vector3(float(c["x"]), 1.35, -2.12)
		var gm := StandardMaterial3D.new()
		gm.albedo_color = Color(1.0, 0.75, 0.35, 0.0)
		gm.emission_enabled = true
		gm.emission = Color(1.0, 0.7, 0.3)
		gm.emission_energy_multiplier = 0.0
		gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		gm.cull_mode = BaseMaterial3D.CULL_DISABLED
		glow.material_override = gm
		glow.name = "Glow_%d" % i
		add_child(glow)
		_machines.append({"cab": cab, "glow": glow, "scene": str(c["scene"]), "x": float(c["x"])})
	_cam = Camera3D.new()
	_cam.fov = 55.0
	_cam.position = Vector3(0, 1.6, 2.4)
	_cam.current = true
	add_child(_cam)
	_apply_look()
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 2.6, 0)
	lamp.light_color = Color(1.0, 0.7, 0.4)
	lamp.light_energy = 2.8
	lamp.omni_range = 12.0
	add_child(lamp)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-25, 160, 0)
	fill.light_color = Color(0.3, 0.4, 0.65)
	fill.light_energy = 0.35
	add_child(fill)
	var layer := CanvasLayer.new()
	layer.layer = 12
	add_child(layer)
	_hint = Label.new()
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
	_hint.text = "Look at a machine · click or Space to sit"
	layer.add_child(_hint)
	var back := TextureButton.new()
	back.texture_normal = load("res://art/seasons/paloma/btn_house.png")
	back.ignore_texture_size = true
	back.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	back.custom_minimum_size = Vector2(56, 56)
	back.position = Vector2(24, 24)
	back.pressed.connect(func() -> void:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Game.goto("lobby")
	)
	layer.add_child(back)


func _apply_look() -> void:
	_cam.rotation = Vector3(_pitch, _yaw, 0.0)


func _update_hover() -> void:
	# Which machine are we looking toward?
	var best: int = -1
	var best_score: float = 999.0
	for i in _machines.size():
		var mx: float = float((_machines[i] as Dictionary)["x"])
		# Desired yaw to face this machine from cam origin
		var want: float = -atan2(mx, 2.15 + 2.4)  # rough
		# Simpler: map yaw bands
		var score: float = absf(_yaw + mx * 0.22)
		if score < best_score:
			best_score = score
			best = i
	if best_score > 0.28:
		best = -1
	_hovered = best
	for i in _machines.size():
		var g: MeshInstance3D = (_machines[i] as Dictionary)["glow"]
		var m: StandardMaterial3D = g.material_override
		if i == _hovered:
			m.albedo_color.a = 0.35
			m.emission_energy_multiplier = 1.6
			_hint.text = "Sit at this machine"
		else:
			m.albedo_color.a = 0.0
			m.emission_energy_multiplier = 0.0
	if _hovered < 0:
		_hint.text = "Look at a machine · click or Space to sit"


func _try_sit() -> void:
	if _hovered < 0 or _entering:
		_hint.text = "Turn to face a machine first"
		return
	if not PlaySafe.chance_staking_allowed():
		Game.toast(Game.text("cool_off_on"))
		return
	_entering = true
	var mx: float = float((_machines[_hovered] as Dictionary)["x"])
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_cam, "position", Vector3(mx, 1.45, -0.55), 0.9)
	tw.parallel().tween_property(_cam, "rotation", Vector3(0.05, 0.0, 0.0), 0.9)
	await tw.finished
	Game.enter_chance_room("slot_palm")
