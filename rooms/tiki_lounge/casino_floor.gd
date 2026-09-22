extends Node3D
## Walk the 3D lounge, approach matching cabinets, sit into the polished face.

const ROOM := "res://art/models/casino_lounge.glb"
const CabinetBuilderScript := preload("res://rooms/tiki_lounge/cabinet_builder.gd")

var _player: CharacterBody3D
var _cam: Camera3D
var _hint: Label
var _sit_btn: Button
var _cabinets: Array = []
var _hover: int = -1
var _entering: bool = false
var _yaw: float = 0.0
var _pitch: float = 0.0


func _ready() -> void:
	_build()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_physics_process(true)


func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(_delta: float) -> void:
	if _entering or _player == null:
		return
	var input := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		input.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		input.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		input.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		input.y += 1
	input = input.limit_length(1.0)
	var basis := Basis.from_euler(Vector3(0, _yaw, 0))
	var move := (-basis.z * -input.y + basis.x * input.x) * 3.6
	_player.velocity = Vector3(move.x, 0, move.z)
	_player.move_and_slide()
	# Keep player in the lounge
	_player.position.x = clampf(_player.position.x, -5.5, 5.5)
	_player.position.z = clampf(_player.position.z, -3.5, 3.8)
	_update_hover()


func _unhandled_input(event: InputEvent) -> void:
	if _entering:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mm := event as InputEventMouseMotion
		_yaw -= mm.relative.x * 0.0025
		_pitch -= mm.relative.y * 0.0020
		_pitch = clampf(_pitch, -0.4, 0.4)
		_cam.rotation = Vector3(_pitch, 0, 0)
		_player.rotation.y = _yaw
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _hover >= 0:
			_sit(_hover)
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("walk"):
		if _hover >= 0:
			_sit(_hover)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Game.goto("lobby")
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _build() -> void:
	RenderingServer.set_default_clear_color(Color(0.05, 0.04, 0.03))
	var room_ps: PackedScene = load(ROOM)
	var room: Node3D = room_ps.instantiate()
	room.name = "LoungeMesh"
	_paint_room(room)
	add_child(room)
	var floor_body := StaticBody3D.new()
	var floor_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(14, 0.2, 10)
	floor_shape.shape = box
	floor_body.position = Vector3(0, -0.05, 0)
	floor_body.add_child(floor_shape)
	add_child(floor_body)

	_player = CharacterBody3D.new()
	_player.name = "Player"
	_player.position = Vector3(0, 0.1, 1.8)
	var pcol := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.28
	cap.height = 1.5
	pcol.shape = cap
	pcol.position.y = 0.85
	_player.add_child(pcol)
	_cam = Camera3D.new()
	_cam.name = "Cam"
	_cam.fov = 68.0
	_cam.position = Vector3(0, 1.55, 0)
	_cam.current = true
	_player.add_child(_cam)
	add_child(_player)
	_yaw = 0.0
	_player.rotation.y = 0.0

	# Three matching cabinets in a bank, facing the player (+Z)
	_cabinets.clear()
	for i in 3:
		var x: float = -2.6 + float(i) * 2.2
		var cab: Node3D = CabinetBuilderScript.build(self, Vector3(x, 0, -2.0), 1.0)
		cab.name = "Cabinet_%d" % i
		var glow := MeshInstance3D.new()
		var tor := TorusMesh.new()
		tor.inner_radius = 0.5
		tor.outer_radius = 0.64
		glow.mesh = tor
		glow.position = Vector3(0, 0.04, 0.42)
		glow.rotation_degrees = Vector3(90, 0, 0)
		var gm := StandardMaterial3D.new()
		gm.albedo_color = Color(1.0, 0.75, 0.35, 0.0)
		gm.emission_enabled = true
		gm.emission = Color(1.0, 0.7, 0.3)
		gm.emission_energy_multiplier = 0.0
		gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		glow.material_override = gm
		glow.name = "SitGlow"
		cab.add_child(glow)
		_cabinets.append({"root": cab, "glow": glow})
	_build_next_tide_plinth()

	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 2.5, 0.5)
	lamp.light_color = Color(1.0, 0.75, 0.45)
	lamp.light_energy = 4.5
	lamp.omni_range = 18.0
	add_child(lamp)
	var key := SpotLight3D.new()
	key.light_color = Color(1.0, 0.88, 0.65)
	key.light_energy = 6.5
	key.spot_range = 14.0
	key.spot_angle = 55.0
	add_child(key)
	key.position = Vector3(0, 2.6, 2.8)
	key.look_at(Vector3(0, 1.0, -2.0), Vector3.UP)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-40, 25, 0)
	fill.light_color = Color(0.55, 0.62, 0.8)
	fill.light_energy = 0.9
	add_child(fill)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.08, 0.07, 0.06)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.55, 0.42, 0.32)
	e.ambient_light_energy = 1.15
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.glow_enabled = true
	e.glow_intensity = 0.35
	env.environment = e
	add_child(env)

	var layer := CanvasLayer.new()
	add_child(layer)
	_hint = Label.new()
	_hint.name = "Hint"
	_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hint.offset_top = -70
	_hint.offset_bottom = -28
	_hint.offset_left = -520
	_hint.offset_right = 520
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 18)
	_hint.add_theme_color_override("font_color", Color(0.97, 0.94, 0.88))
	_hint.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.05))
	_hint.add_theme_constant_override("outline_size", 5)
	_hint.text = "WASD move · mouse look · approach a cabinet"
	layer.add_child(_hint)
	_sit_btn = Button.new()
	_sit_btn.name = "SitBtn"
	_sit_btn.text = "Sit"
	_sit_btn.visible = false
	_sit_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_sit_btn.offset_left = -90
	_sit_btn.offset_right = 90
	_sit_btn.offset_top = -140
	_sit_btn.offset_bottom = -84
	_sit_btn.add_theme_font_size_override("font_size", 24)
	var sbs := StyleBoxFlat.new()
	sbs.bg_color = Color(0.85, 0.55, 0.22)
	sbs.set_corner_radius_all(10)
	sbs.set_border_width_all(2)
	sbs.border_color = Color(0.75, 0.5, 0.25)
	_sit_btn.add_theme_stylebox_override("normal", sbs)
	_sit_btn.add_theme_color_override("font_color", Color(0.97, 0.94, 0.88))
	_sit_btn.pressed.connect(func() -> void:
		if _hover >= 0:
			_sit(_hover)
	)
	layer.add_child(_sit_btn)


func _build_next_tide_plinth() -> void:
	var p := Node3D.new()
	p.name = "NextTide"
	p.position = Vector3(3.9, 0, -2.0)
	add_child(p)
	CabinetBuilderScript.box(p, Vector3(0.9, 0.22, 0.7), Vector3(0, 0.12, 0), CabinetBuilderScript.wood_mat(Color(0.28, 0.16, 0.08)), "Plinth")
	var sign := Label3D.new()
	sign.text = "Coming with\nthe next tide"
	sign.font_size = 36
	sign.pixel_size = 0.0035
	sign.modulate = Color(0.92, 0.86, 0.72)
	sign.outline_modulate = Color(0.08, 0.05, 0.03)
	sign.outline_size = 8
	sign.position = Vector3(0, 0.42, 0.2)
	sign.name = "PlinthSign"
	p.add_child(sign)


func _paint_room(room: Node) -> void:
	var floor_m := StandardMaterial3D.new()
	floor_m.albedo_color = Color(0.42, 0.26, 0.14)
	floor_m.roughness = 0.55
	var wall_m := StandardMaterial3D.new()
	wall_m.albedo_color = Color(0.72, 0.62, 0.5)
	wall_m.roughness = 0.7
	var thatch_m := StandardMaterial3D.new()
	thatch_m.albedo_color = Color(0.55, 0.38, 0.18)
	thatch_m.roughness = 0.85
	var ocean_m := StandardMaterial3D.new()
	ocean_m.albedo_color = Color(0.08, 0.18, 0.32)
	ocean_m.roughness = 0.25
	for mi in room.find_children("*", "MeshInstance3D", true, false):
		var mesh_i := mi as MeshInstance3D
		var n: String = mesh_i.name.to_lower()
		if n.find("floor") != -1:
			mesh_i.material_override = floor_m
		elif n.find("roof") != -1 or n.find("thatch") != -1:
			mesh_i.material_override = thatch_m
		elif n.find("ocean") != -1:
			mesh_i.material_override = ocean_m
		else:
			mesh_i.material_override = wall_m


func _update_hover() -> void:
	_hover = -1
	var best_d := 2.4
	for i in _cabinets.size():
		var cab: Node3D = (_cabinets[i] as Dictionary)["root"]
		var d: float = _player.global_position.distance_to(cab.global_position + Vector3(0, 0, 0.5))
		var to_cab: Vector3 = (cab.global_position - _player.global_position)
		to_cab.y = 0
		if to_cab.length() < 0.01:
			continue
		var facing: float = (-_player.global_transform.basis.z).dot(to_cab.normalized())
		if d < best_d and facing > 0.15:
			best_d = d
			_hover = i
	for i in _cabinets.size():
		var glow: MeshInstance3D = (_cabinets[i] as Dictionary)["glow"]
		var gm: StandardMaterial3D = glow.material_override
		if i == _hover:
			gm.albedo_color.a = 0.65
			gm.emission_energy_multiplier = 2.4
		else:
			gm.albedo_color.a = 0.0
			gm.emission_energy_multiplier = 0.0
	_sit_btn.visible = _hover >= 0
	if _hover >= 0:
		_hint.text = "Sit at this machine"
	else:
		_hint.text = "WASD move · mouse look · approach a cabinet"


func _sit(idx: int) -> void:
	if _entering or idx < 0 or idx >= _cabinets.size():
		return
	if not PlaySafe.chance_staking_allowed():
		Game.toast(Game.text("cool_off_on"))
		return
	_entering = true
	_sit_btn.visible = false
	_hint.text = ""
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var cab: Node3D = (_cabinets[idx] as Dictionary)["root"]
	var rw: Node3D = cab.find_child("ReelWindow", true, false) as Node3D
	var glass: Vector3 = cab.global_position + Vector3(0, 1.18, 0.45)
	if rw:
		glass = rw.global_position
	var cam_pos: Vector3 = glass + Vector3(0, -0.28, 2.5)
	# Detach cam from player for the dolly
	var gpos: Vector3 = _cam.global_position
	var grot: Vector3 = _cam.global_rotation
	_player.remove_child(_cam)
	add_child(_cam)
	_cam.global_position = gpos
	_cam.global_rotation = grot
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_cam, "global_position", cam_pos, 0.75)
	tw.parallel().tween_callback(func() -> void:
		_cam.look_at(glass + Vector3(0, 0.35, 0), Vector3.UP)
	)
	tw.tween_callback(func() -> void: Game.enter_chance_room("slot_palm"))
