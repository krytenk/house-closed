extends Node3D
## Paloma House lobby — walk the room, enter the hall. No text-box menu.

const LOBBY_TEX := "res://art/seasons/paloma/lobby_interior.png"

var _cam: Camera3D
var _yaw: float = 0.0
var _pitch: float = 0.0
var _entering: bool = false
var _hint: Label
var _mara: Label
var _door_glow: MeshInstance3D
var _shot_path: String = ""
var _shot_frames: int = 0


func _ready() -> void:
	_build()
	_shot_path = OS.get_environment("PALM_SHOT")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process(true)
	if not Save.first_run_complete:
		_show_mara()


func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(delta: float) -> void:
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
	# Soft door pulse
	if _door_glow:
		var a: float = 0.35 + 0.25 * sin(Time.get_ticks_msec() / 400.0)
		var m: StandardMaterial3D = _door_glow.material_override
		if m:
			m.albedo_color.a = a
			m.emission_energy_multiplier = 0.8 + a


func _unhandled_input(event: InputEvent) -> void:
	if _entering:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mm := event as InputEventMouseMotion
		_yaw -= mm.relative.x * 0.0022
		_pitch -= mm.relative.y * 0.0020
		_yaw = clampf(_yaw, -0.55, 0.55)
		_pitch = clampf(_pitch, -0.25, 0.28)
		_apply_look()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_enter_hall()
	if event.is_action_pressed("walk") or event.is_action_pressed("ui_accept"):
		_try_enter_hall()
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Game.goto("pause")
	if event is InputEventKey and event.pressed and event.keycode == KEY_G:
		_garden()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _build() -> void:
	RenderingServer.set_default_clear_color(Color(0.08, 0.07, 0.06))
	# Lobby plate — you stand in the room looking at it
	var plate := MeshInstance3D.new()
	var pm := QuadMesh.new()
	pm.size = Vector2(19.2, 10.8)
	plate.mesh = pm
	plate.position = Vector3(0, 1.55, -4.2)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load(LOBBY_TEX)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	plate.material_override = mat
	add_child(plate)
	# Floor under you
	var floor := MeshInstance3D.new()
	var fm := PlaneMesh.new()
	fm.size = Vector2(12, 8)
	floor.mesh = fm
	floor.position = Vector3(0, 0, 0)
	var fm_mat := StandardMaterial3D.new()
	fm_mat.albedo_color = Color(0.55, 0.42, 0.28)
	fm_mat.roughness = 0.7
	floor.material_override = fm_mat
	add_child(floor)
	# Doorway glow — right hall into the lounge (no text)
	_door_glow = MeshInstance3D.new()
	var gm := QuadMesh.new()
	gm.size = Vector2(3.2, 5.0)
	_door_glow.mesh = gm
	_door_glow.position = Vector3(5.2, 2.1, -4.0)
	var gm_mat := StandardMaterial3D.new()
	gm_mat.albedo_color = Color(1.0, 0.78, 0.45, 0.55)
	gm_mat.emission_enabled = true
	gm_mat.emission = Color(1.0, 0.72, 0.35)
	gm_mat.emission_energy_multiplier = 2.2
	gm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gm_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_door_glow.material_override = gm_mat
	add_child(_door_glow)
	# Arrow cue on the floor toward the hall
	var arrow := MeshInstance3D.new()
	var am := PrismMesh.new()
	am.size = Vector3(0.6, 0.08, 0.9)
	arrow.mesh = am
	arrow.position = Vector3(1.8, 0.06, 0.2)
	arrow.rotation_degrees = Vector3(0, -55, 0)
	var am_mat := StandardMaterial3D.new()
	am_mat.albedo_color = Color(1.0, 0.75, 0.35)
	am_mat.emission_enabled = true
	am_mat.emission = Color(1.0, 0.7, 0.3)
	am_mat.emission_energy_multiplier = 1.5
	am_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	arrow.material_override = am_mat
	add_child(arrow)
	# Camera at standing height in the lobby
	_cam = Camera3D.new()
	_cam.fov = 58.0
	_cam.position = Vector3(0.0, 1.62, 1.8)
	_cam.current = true
	add_child(_cam)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 2.8, 0)
	lamp.light_color = Color(1.0, 0.86, 0.65)
	lamp.light_energy = 2.4
	lamp.omni_range = 14.0
	add_child(lamp)
	# Minimal HUD — no menu buttons
	var layer := CanvasLayer.new()
	layer.layer = 12
	add_child(layer)
	_hint = Label.new()
	_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hint.offset_top = -72
	_hint.offset_bottom = -28
	_hint.offset_left = -420
	_hint.offset_right = 420
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 18)
	_hint.add_theme_color_override("font_color", Color(0.97, 0.94, 0.88, 0.85))
	_hint.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.1))
	_hint.add_theme_constant_override("outline_size", 4)
	_hint.text = "Look to the glowing hall · click or Space to walk through"
	layer.add_child(_hint)
	_mara = Label.new()
	_mara.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_mara.offset_top = -120
	_mara.offset_bottom = -78
	_mara.offset_left = -520
	_mara.offset_right = 520
	_mara.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mara.add_theme_font_size_override("font_size", 20)
	_mara.add_theme_color_override("font_color", Color(0.97, 0.94, 0.88))
	_mara.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.1))
	_mara.add_theme_constant_override("outline_size", 5)
	_mara.visible = false
	layer.add_child(_mara)
	# Tiny garden exit — icon only
	var garden := TextureButton.new()
	garden.texture_normal = load("res://art/seasons/paloma/btn_house.png")
	garden.ignore_texture_size = true
	garden.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	garden.custom_minimum_size = Vector2(56, 56)
	garden.position = Vector2(24, 24)
	garden.pressed.connect(_garden)
	garden.tooltip_text = "Garden"
	layer.add_child(garden)
	_apply_look()


func _apply_look() -> void:
	if _cam == null:
		return
	_cam.rotation = Vector3(_pitch, _yaw, 0.0)
	if _hint == null:
		return
	# Looking right (negative yaw) toward the glowing hall
	if _yaw < -0.18:
		_hint.text = "Walk through to the lounge"
	else:
		_hint.text = "Look to the glowing hall · click or Space to walk through"


func _try_enter_hall() -> void:
	if _entering:
		return
	# Must be looking toward the hall (right side of lobby)
	if _yaw > -0.12:
		_hint.text = "Turn toward the glowing hall"
		return
	if not RegionPolicy.chance_rooms_open() or not PlaySafe.lounge_salon_human_allowed():
		Game.toast(Game.text("wa_chance_block") if not RegionPolicy.chance_rooms_open() else Game.text("self_exclude_on"))
		return
	_entering = true
	_hint.text = ""
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_cam, "position", Vector3(3.8, 1.62, -1.2), 1.15)
	tw.parallel().tween_property(_cam, "rotation", Vector3(0.0, -0.55, 0.0), 1.15)
	await tw.finished
	Game.goto("casino_floor")


func _show_mara() -> void:
	_mara.text = Game.text("mara_welcome")
	_mara.visible = true
	get_tree().create_timer(4.5).timeout.connect(func() -> void:
		if is_instance_valid(_mara):
			_mara.visible = false
	)


func _garden() -> void:
	Save.first_run_complete = true
	Save.write_disk()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Game.goto("island")
