extends Node3D
## 3D casino lounge — walk among real cabinets, sit to play.

const ROOM := "res://art/models/casino_lounge.glb"
const CABINET := "res://art/models/tiki_cabinet.glb"

var _player: CharacterBody3D
var _cam: Camera3D
var _hint: Label
var _cabinets: Array = []
var _hover: int = -1
var _entering: bool = false
var _yaw: float = 0.0
var _pitch: float = 0.0


func _ready() -> void:
	_build()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process(true)
	set_physics_process(true)


func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta: float) -> void:
	if _entering or _player == null:
		return
	var input := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	# Also WASD via physical keys
	if Input.is_key_pressed(KEY_A):
		input.x -= 1
	if Input.is_key_pressed(KEY_D):
		input.x += 1
	if Input.is_key_pressed(KEY_W):
		input.y -= 1
	if Input.is_key_pressed(KEY_S):
		input.y += 1
	input = input.limit_length(1.0)
	var basis := Basis.from_euler(Vector3(0, _yaw, 0))
	var move := (-basis.z * -input.y + basis.x * input.x) * 3.6
	_player.velocity.x = move.x
	_player.velocity.z = move.z
	_player.velocity.y = 0
	_player.move_and_slide()
	_update_hover()


func _unhandled_input(event: InputEvent) -> void:
	if _entering:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mm := event as InputEventMouseMotion
		_yaw -= mm.relative.x * 0.0025
		_pitch -= mm.relative.y * 0.0020
		_pitch = clampf(_pitch, -0.45, 0.45)
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
	RenderingServer.set_default_clear_color(Color(0.03, 0.04, 0.06))
	var room_ps: PackedScene = load(ROOM)
	var room: Node3D = room_ps.instantiate()
	room.name = "LoungeMesh"
	_paint_room(room)
	add_child(room)
	# Floor collision
	var floor_body := StaticBody3D.new()
	var floor_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(14, 0.2, 10)
	floor_shape.shape = box
	floor_body.position = Vector3(0, -0.05, 0)
	floor_body.add_child(floor_shape)
	add_child(floor_body)
	# Player
	_player = CharacterBody3D.new()
	_player.name = "Player"
	var spawn := _find_named(room, "PlayerSpawn")
	_player.position = spawn.global_position if spawn else Vector3(0, 0.1, -1.5)
	_player.position.y = 0.1
	var pcol := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.28
	cap.height = 1.5
	pcol.shape = cap
	pcol.position.y = 0.85
	_player.add_child(pcol)
	_cam = Camera3D.new()
	_cam.name = "Cam"
	_cam.fov = 70.0
	_cam.position = Vector3(0, 1.55, 0)
	_cam.current = true
	_player.add_child(_cam)
	add_child(_player)
	# Cabinets at spawn markers
	var cab_ps: PackedScene = load(CABINET)
	_cabinets.clear()
	for i in 3:
		var marker := _find_named(room, "CabinetSpawn_%d" % i)
		var cab: Node3D = cab_ps.instantiate()
		cab.name = "Cabinet_%d" % i
		if marker:
			cab.global_transform = marker.global_transform
		else:
			cab.position = Vector3(-2.4 + float(i) * 2.4, 0, 2.2)
		# Face toward player spawn (negative Z in room space roughly toward -Y in blender export)
		# Face player (cabinets sit at -Z; player looks -Z)
		cab.rotate_y(0)
		_paint_cabinet(cab)
		add_child(cab)
		var area := Area3D.new()
		area.name = "SitArea"
		var ashape := CollisionShape3D.new()
		var abox := BoxShape3D.new()
		abox.size = Vector3(1.4, 2.2, 1.2)
		ashape.shape = abox
		ashape.position = Vector3(0, 1.0, 0.4)
		area.add_child(ashape)
		cab.add_child(area)
		_cabinets.append({"root": cab, "area": area})
	# Place player facing the bank
	_player.position = Vector3(0, 0.1, 1.8)
	_yaw = 0.0
	_player.rotation.y = 0.0
	# Lights — warm lounge key + rim on cabinets
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 2.6, 0.5)
	lamp.light_color = Color(1.0, 0.75, 0.45)
	lamp.light_energy = 5.0
	lamp.omni_range = 16.0
	add_child(lamp)
	var key := SpotLight3D.new()
	key.light_color = Color(1.0, 0.85, 0.6)
	key.light_energy = 8.0
	key.spot_range = 12.0
	key.spot_angle = 55.0
	add_child(key)
	key.position = Vector3(0, 2.8, 2.5)
	key.look_at(Vector3(0, 1.0, -2.2), Vector3.UP)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-40, 30, 0)
	fill.light_color = Color(0.45, 0.55, 0.75)
	fill.light_energy = 0.55
	add_child(fill)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.08, 0.06, 0.05)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.35, 0.28, 0.22)
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	add_child(env)
	var layer := CanvasLayer.new()
	add_child(layer)
	_hint = Label.new()
	_hint.name = "Hint"
	_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hint.offset_top = -70
	_hint.offset_bottom = -28
	_hint.offset_left = -500
	_hint.offset_right = 500
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 18)
	_hint.add_theme_color_override("font_color", Color(0.97, 0.94, 0.88))
	_hint.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.05))
	_hint.add_theme_constant_override("outline_size", 5)
	_hint.text = "WASD move · mouse look · click a cabinet to sit"
	layer.add_child(_hint)


func _find_named(root: Node, name: String) -> Node3D:
	var n := root.find_child(name, true, false)
	return n as Node3D


func _paint_room(room: Node) -> void:
	var floor_m := StandardMaterial3D.new()
	floor_m.albedo_color = Color(0.2, 0.11, 0.05)
	floor_m.roughness = 0.6
	var wall_m := StandardMaterial3D.new()
	wall_m.albedo_color = Color(0.18, 0.1, 0.06)
	wall_m.roughness = 0.7
	var thatch_m := StandardMaterial3D.new()
	thatch_m.albedo_color = Color(0.5, 0.34, 0.16)
	thatch_m.roughness = 0.85
	var ocean_m := StandardMaterial3D.new()
	ocean_m.albedo_color = Color(0.03, 0.1, 0.18)
	ocean_m.roughness = 0.2
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


func _paint_cabinet(cab: Node) -> void:
	## Ensure imported meshes read as carved wood under Compatibility renderer.
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.32, 0.16, 0.07)
	wood.roughness = 0.42
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.14, 0.07, 0.03)
	dark.roughness = 0.5
	var amber := StandardMaterial3D.new()
	amber.albedo_color = Color(0.95, 0.55, 0.15)
	amber.emission_enabled = true
	amber.emission = Color(0.95, 0.45, 0.1)
	amber.emission_energy_multiplier = 1.2
	for mi in cab.find_children("*", "MeshInstance3D", true, false):
		var mesh_i := mi as MeshInstance3D
		var n: String = mesh_i.name.to_lower()
		if n.find("eye") != -1:
			mesh_i.material_override = amber
		elif n.find("dark") != -1 or n.find("mouth") != -1 or n.find("brow") != -1 or n.find("belly") != -1 or n.find("side") != -1 or n.find("leg") != -1 or n.find("base") != -1:
			mesh_i.material_override = dark
		elif n.find("glass") != -1:
			var g := StandardMaterial3D.new()
			g.albedo_color = Color(0.04, 0.04, 0.05, 0.65)
			g.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			g.roughness = 0.08
			mesh_i.material_override = g
		else:
			mesh_i.material_override = wood


func _update_hover() -> void:
	_hover = -1
	if _player == null:
		return
	var best_d := 2.4
	for i in _cabinets.size():
		var cab: Node3D = (_cabinets[i] as Dictionary)["root"]
		var d: float = _player.global_position.distance_to(cab.global_position)
		# Must roughly face the cabinet
		var to_cab: Vector3 = (cab.global_position - _player.global_position).normalized()
		var forward: Vector3 = -_player.global_transform.basis.z
		var facing: float = forward.dot(to_cab)
		if d < best_d and facing > 0.35:
			best_d = d
			_hover = i
	if _hover >= 0:
		_hint.text = "Click or Space — sit at machine"
	else:
		_hint.text = "WASD move · mouse look · approach a cabinet"


func _sit(idx: int) -> void:
	if _entering:
		return
	if not PlaySafe.chance_staking_allowed():
		Game.toast(Game.text("cool_off_on"))
		return
	_entering = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var cab: Node3D = (_cabinets[idx] as Dictionary)["root"]
	var target: Vector3 = cab.global_position + cab.global_transform.basis.z * 1.15 + Vector3(0, 1.45, 0)
	var look_at_pt: Vector3 = cab.global_position + Vector3(0, 1.35, 0)
	var tw := create_tween()
	tw.tween_property(_cam, "global_position", target, 0.65)
	tw.parallel().tween_callback(func() -> void:
		_cam.look_at(look_at_pt, Vector3.UP)
	)
	tw.tween_callback(func() -> void: Game.enter_chance_room("slot_palm"))
