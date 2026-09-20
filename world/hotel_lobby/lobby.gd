extends Node3D
## 3D boutique lobby — walk to the glowing hall. No photo wallpaper.

const ROOM := "res://art/models/lobby_room.glb"

var _player: CharacterBody3D
var _cam: Camera3D
var _hint: Label
var _mara: Label
var _yaw: float = 0.0
var _pitch: float = 0.0
var _entering: bool = false
var _hall: Node3D


func _ready() -> void:
	_build()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_physics_process(true)
	if not Save.first_run_complete:
		_show_mara()


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
	var move := (-basis.z * -input.y + basis.x * input.x) * 3.4
	_player.velocity = Vector3(move.x, 0, move.z)
	_player.move_and_slide()
	_update_hint()


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
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("walk"):
		if _near_hall():
			_enter_hall()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _near_hall():
			_enter_hall()
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
	RenderingServer.set_default_clear_color(Color(0.55, 0.48, 0.4))
	var room_ps: PackedScene = load(ROOM)
	var room: Node3D = room_ps.instantiate()
	room.name = "LobbyMesh"
	add_child(room)
	var floor_body := StaticBody3D.new()
	var fs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(12, 0.2, 10)
	fs.shape = box
	floor_body.position = Vector3(0, -0.05, 0)
	floor_body.add_child(fs)
	add_child(floor_body)
	_hall = room.find_child("HallPortal", true, false) as Node3D
	# Hall trigger volume
	var hall_area := Area3D.new()
	hall_area.name = "HallArea"
	var hs := CollisionShape3D.new()
	var hbox := BoxShape3D.new()
	hbox.size = Vector3(2.2, 2.4, 2.0)
	hs.shape = hbox
	hall_area.add_child(hs)
	if _hall:
		hall_area.global_position = _hall.global_position + Vector3(0, 1.2, 0)
	else:
		hall_area.position = Vector3(5.2, 1.2, 0)
	add_child(hall_area)
	# Soft hall glow
	var glow := MeshInstance3D.new()
	var gq := QuadMesh.new()
	gq.size = Vector2(1.8, 2.6)
	glow.mesh = gq
	glow.position = hall_area.position + Vector3(-0.3, 0.2, 0)
	glow.rotation_degrees = Vector3(0, 90, 0)
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color(1.0, 0.78, 0.4, 0.35)
	gm.emission_enabled = true
	gm.emission = Color(1.0, 0.7, 0.3)
	gm.emission_energy_multiplier = 1.8
	gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gm.cull_mode = BaseMaterial3D.CULL_DISABLED
	glow.material_override = gm
	glow.name = "HallGlow"
	add_child(glow)
	_player = CharacterBody3D.new()
	_player.name = "Player"
	var spawn := room.find_child("PlayerSpawn", true, false) as Node3D
	_player.position = spawn.global_position if spawn else Vector3(0, 0.1, 2.2)
	_player.position.y = 0.1
	var pcol := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.28
	cap.height = 1.5
	pcol.shape = cap
	pcol.position.y = 0.85
	_player.add_child(pcol)
	_cam = Camera3D.new()
	_cam.fov = 70.0
	_cam.position = Vector3(0, 1.55, 0)
	_cam.current = true
	_player.add_child(_cam)
	add_child(_player)
	# Face the glowing hall (positive X)
	_yaw = -PI * 0.5
	_player.rotation.y = _yaw
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 2.5, 0)
	lamp.light_color = Color(1.0, 0.9, 0.75)
	lamp.light_energy = 3.2
	lamp.omni_range = 12.0
	add_child(lamp)
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
	_hint.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.1))
	_hint.add_theme_constant_override("outline_size", 5)
	_hint.text = "WASD move · mouse look · walk into the glowing hall"
	layer.add_child(_hint)
	_mara = Label.new()
	_mara.name = "MaraLine"
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
	var garden := TextureButton.new()
	garden.name = "GardenBtn"
	garden.texture_normal = load("res://art/seasons/paloma/btn_house.png")
	garden.ignore_texture_size = true
	garden.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	garden.custom_minimum_size = Vector2(56, 56)
	garden.position = Vector2(24, 24)
	garden.pressed.connect(_garden)
	garden.tooltip_text = "Garden"
	layer.add_child(garden)


func _near_hall() -> bool:
	if _hall == null:
		return _player.global_position.distance_to(Vector3(5.2, 0.1, 0)) < 2.2
	return _player.global_position.distance_to(_hall.global_position) < 2.3


func _update_hint() -> void:
	if _near_hall():
		_hint.text = "Click or Space — walk through to the lounge"
	else:
		_hint.text = "WASD move · mouse look · walk into the glowing hall"


func _enter_hall() -> void:
	if _entering:
		return
	if not RegionPolicy.chance_rooms_open() or not PlaySafe.lounge_salon_human_allowed():
		Game.toast(Game.text("wa_chance_block") if not RegionPolicy.chance_rooms_open() else Game.text("self_exclude_on"))
		return
	_entering = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var tw := create_tween()
	var target := _hall.global_position if _hall else Vector3(5.5, 1.55, 0)
	target.y = 1.55
	tw.tween_property(_cam, "global_position", target, 0.85)
	tw.tween_callback(func() -> void: Game.goto("casino_floor"))


func _show_mara() -> void:
	_mara.text = Game.text("mara_welcome")
	_mara.visible = true
	get_tree().create_timer(4.0).timeout.connect(func() -> void:
		if is_instance_valid(_mara):
			_mara.visible = false
	)


func _garden() -> void:
	Save.first_run_complete = true
	Save.write_disk()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Game.goto("island")
