extends Node3D
## House Closed — Room 01. Locked lounge. Deterministic puzzles.

const ROOM := "res://art/models/abandoned_lounge.tscn"
const CabinetBuilderScript := preload("res://rooms/tiki_lounge/cabinet_builder.gd")
const REEL_CYCLE := ["S", "P", "L", "C"]
const JACKPOT := ["P", "L", "C"]

var _player: CharacterBody3D
var _cam: Camera3D
var _hint: Label
var _inv_label: Label
var _wake_label: Label
var _stuck_label: Label
var _pad: Control
var _pad_display: Label
var _complete: ColorRect
var _yaw: float = PI
var _pitch: float = 0.15
var _busy: bool = false
var _hover_id: String = ""
var _last_earned: String = "The door is locked. Look around."
var _pad_value: String = ""
var _flicker: OmniLight3D
var _cabs: Array = []
var _reel_ids: Array = ["S", "S", "S"]
var _flags := {
	"bird_turned": false,
	"coins_dumped": false,
	"notebook": false,
	"wallpaper": false,
	"coins_in_tray": 0,
	"jackpot": false,
	"fuse": false,
	"fuse_in": false,
	"code_ok": false,
	"has_key": false,
	"door_open": false,
	"cleared": false,
	"flashlight": false,
	"notice": false,
}
var _door: Node3D
var _chain: Node3D
var _pelican: Node3D
var _bird_spin: Node3D
var _turning: bool = false
var _paper_flap: Node3D
var _register_light: OmniLight3D
var _lamp: OmniLight3D
var _fill: DirectionalLight3D
var _env: Environment
var _blink: ColorRect
var _narration: Label
var _code_label: Label3D
var _bed: AudioStreamPlayer
var _bed_pending: bool = false
var _slip: Node3D
var _notebook_mesh: Node3D
var _notice: Node3D
var _hover_node: Node
var _lounge: Node3D


func _ready() -> void:
	EscapeInventory.reset()
	_build_room()
	_build_player()
	_build_cabinets()
	_build_door()
	_build_register()
	_dress()
	_age_the_house()
	_build_hud()
	_restore_progress()
	if bool(_flags["cleared"]):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_physics_process(true)
	_wake()


func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(delta: float) -> void:
	if _bed_pending and _bed and not _bed.playing:
		_bed.play()
		if _bed.playing:
			_bed_pending = false
	if _flicker and not bool(_flags["fuse"]):
		_flicker.light_energy = 1.2 + sin(Time.get_ticks_msec() * 0.012) * 0.7 + randf() * 0.15
	if _wake_label and _wake_label.visible:
		_wake_label.modulate.a = maxf(0.0, _wake_label.modulate.a - delta * 0.18)
		if _wake_label.modulate.a <= 0.0:
			_wake_label.visible = false


func _physics_process(_delta: float) -> void:
	if _busy or _player == null or _pad.visible or _complete.visible:
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
	var move := (-basis.z * -input.y + basis.x * input.x) * 3.2
	_player.velocity = Vector3(move.x, 0, move.z)
	_player.move_and_slide()
	_player.position.x = clampf(_player.position.x, -6.5, 6.5)
	_player.position.z = clampf(_player.position.z, -4.6, 4.6)
	_update_hover()


func _unhandled_input(event: InputEvent) -> void:
	if _complete.visible:
		return
	if _pad.visible:
		_pad_input(event)
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _hover_id == "bird" and not _flags["bird_turned"]:
			_turning = true
			return
		if not event.pressed:
			if _turning:
				_turning = false
				_finish_turn()
				return
			_use()
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mm := event as InputEventMouseMotion
		if _turning and _bird_spin:
			_bird_spin.rotate_y(-mm.relative.x * 0.012)
			return
		_yaw -= mm.relative.x * 0.0025
		_pitch -= mm.relative.y * 0.0020
		_pitch = clampf(_pitch, -1.05, 0.55)
		_cam.rotation = Vector3(_pitch, 0, 0)
		_player.rotation.y = _yaw
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("walk"):
		if _hover_id == "bird":
			_nudge_bird()
		else:
			_use()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			if _hover_id == "bird":
				_nudge_bird()
			else:
				_use()
		elif event.keycode >= KEY_1 and event.keycode <= KEY_8:
			EscapeInventory.selected = mini(event.keycode - KEY_1, maxi(0, EscapeInventory.slots.size() - 1))
			EscapeInventory.changed.emit()
		elif event.keycode == KEY_ESCAPE:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				_stuck_label.visible = true
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				_stuck_label.visible = false
		elif event.keycode == KEY_H:
			_stuck_label.visible = not _stuck_label.visible


func _wake() -> void:
	var spawn: Node3D = _named("PlayerSpawn")
	if spawn:
		_player.position = spawn.global_position
		_player.position.y = 0.1
	else:
		_player.position = Vector3(-2.5, 0.1, 1.15)
	_yaw = 0.0
	_pitch = 0.08
	_player.rotation.y = _yaw
	_cam.rotation = Vector3(_pitch, 0, 0)
	_wake_label.visible = false
	if bool(_flags["cleared"]):
		_start_bed()
		return
	_blink_awake()


func _build_room() -> void:
	RenderingServer.set_default_clear_color(Color(0.04, 0.03, 0.02))
	var room_ps: PackedScene = load(ROOM)
	_lounge = room_ps.instantiate()
	_lounge.name = "LoungeMesh"
	add_child(_lounge)
	for L in _lounge.find_children("*", "Light3D", true, false):
		var light := L as Light3D
		light.light_energy = clampf(light.light_energy, 0.0, 3.5)
		if light is OmniLight3D:
			(light as OmniLight3D).omni_range = clampf((light as OmniLight3D).omni_range, 1.0, 16.0)
	var floor_body := StaticBody3D.new()
	var floor_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(14, 0.2, 10)
	floor_shape.shape = box
	floor_body.position = Vector3(0, -0.05, 0)
	floor_body.add_child(floor_shape)
	add_child(floor_body)
	_lamp = OmniLight3D.new()
	_lamp.name = "CeilingLamp"
	_lamp.position = Vector3(0, 2.4, 0.2)
	_lamp.light_color = Color(1.0, 0.55, 0.32)
	_lamp.light_energy = 0.85
	_lamp.omni_range = 11.0
	add_child(_lamp)
	_flicker = OmniLight3D.new()
	_flicker.name = "FlickerLantern"
	var lantern: Node3D = _named("LanternFuse")
	_flicker.position = lantern.global_position if lantern else Vector3(-2.2, 2.2, 1.4)
	_flicker.light_color = Color(1.0, 0.7, 0.3)
	_flicker.light_energy = 1.8
	_flicker.omni_range = 7.0
	add_child(_flicker)
	if lantern:
		_mark(lantern, "lantern", Vector3(0.35, 0.5, 0.35), Vector3.ZERO)
	else:
		_mark(_flicker, "lantern", Vector3(0.3, 0.4, 0.3), Vector3.ZERO)
	_board_the_window()
	_collide_room()
	_fill = DirectionalLight3D.new()
	_fill.rotation_degrees = Vector3(-50, 30, 0)
	_fill.light_color = Color(0.85, 0.68, 0.48)
	_fill.light_energy = 0.18
	add_child(_fill)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.03, 0.025, 0.02)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.22, 0.16, 0.12)
	e.ambient_light_energy = 0.32
	_env = e
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.fog_enabled = true
	e.fog_light_color = Color(0.08, 0.06, 0.04)
	e.fog_density = 0.004
	env.environment = e
	add_child(env)


func _build_player() -> void:
	_player = CharacterBody3D.new()
	_player.name = "Player"
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
	_cam.position = Vector3(0, 1.5, 0)
	_cam.current = true
	_player.add_child(_cam)
	add_child(_player)


func _named(n: String) -> Node3D:
	if _lounge == null:
		return null
	return _lounge.find_child(n, true, false) as Node3D


func _build_cabinets() -> void:
	_cabs.clear()
	for i in 3:
		var spawn: Node3D = _named("CabinetSpawn_%d" % i)
		var pos := Vector3(-2.5 + float(i) * 2.5, 0, -2.15)
		if spawn:
			pos = spawn.global_position
			pos.y = 0.0
		var cab: Node3D = CabinetBuilderScript.build(self, pos, 1.0)
		cab.name = "Cabinet_%d" % i
		_cabs.append(cab)
		var tiny: Node3D = cab.find_child("Pelican", true, false) as Node3D
		if tiny:
			tiny.visible = false
		if i == 0:
			_pelican = CabinetBuilderScript.build_statue_bird(cab, Vector3(0.0, 1.88, 0.55))
			_bird_spin = _pelican.get_node("Spin") as Node3D
			_bird_spin.rotation_degrees.y = 32.0
			_mark(_pelican, "bird", Vector3(1.0, 1.2, 1.0), Vector3(0.15, 0.35, 0.2))
			var bodycol: CollisionShape3D = cab.find_child("BodyCol", true, false).get_child(0) as CollisionShape3D if cab.find_child("BodyCol", true, false) else null
			if bodycol and bodycol.shape is BoxShape3D:
				(bodycol.shape as BoxShape3D).size = Vector3(1.25, 1.6, 0.85)
				bodycol.position.y = 0.85
			var tape := MeshInstance3D.new()
			var tmesh := BoxMesh.new()
			tmesh.size = Vector3(0.95, 0.12, 0.04)
			tape.mesh = tmesh
			tape.position = Vector3(0, 1.18, 0.48)
			tape.rotation_degrees = Vector3(0, 0, 18)
			tape.material_override = CabinetBuilderScript.mat(Color(0.75, 0.62, 0.28), 0.7)
			tape.name = "Tape"
			cab.add_child(tape)
			var tag := Label3D.new()
			tag.text = "OUT OF ORDER"
			tag.font_size = 48
			tag.pixel_size = 0.0022
			tag.position = Vector3(0, 1.18, 0.52)
			tag.modulate = Color(0.15, 0.08, 0.04)
			cab.add_child(tag)
		elif i == 1:
			# Tray only. The reel window sits above this and must stay clickable.
			_mark(cab, "setter", Vector3(0.76, 0.32, 0.40), Vector3(0, 0.52, 0.68))
			_wire_reels(cab)
		else:
			_mark(cab, "jammed", Vector3(1.2, 2.2, 1.0), Vector3(0, 1.1, 0.4))


func _wire_reels(cab: Node3D) -> void:
	var anchor: Node3D = cab.find_child("ReelWindow", true, false) as Node3D
	if anchor == null:
		return
	for col in 3:
		var cell: MeshInstance3D = anchor.find_child("Cell_%d_1" % (col + 1), true, false) as MeshInstance3D
		if cell == null:
			continue
		_set_reel_tex(cell, "S")
		# In front of BodyCol (front face at local z 0.475). The cell itself is behind it.
		_mark(cell, "reel_%d" % col, Vector3(0.16, 0.18, 0.08), Vector3(0, 0, 0.16))


func _build_door() -> void:
	_door = _named("HallDoor")
	_chain = _named("Chain")
	if _door == null:
		_door = Node3D.new()
		_door.name = "HallDoor"
		_door.position = Vector3(0, 0, 3.65)
		add_child(_door)
		CabinetBuilderScript.box(_door, Vector3(1.4, 2.4, 0.12), Vector3(0, 1.2, 0), CabinetBuilderScript.mat(Color(0.18, 0.1, 0.06), 0.7), "Slab")
	_mark(_door, "door", Vector3(1.2, 2.2, 0.5), Vector3(0, 0, 0))


func _build_register() -> void:
	var reg: Node3D = _named("Register")
	if reg == null:
		reg = Node3D.new()
		reg.name = "Register"
		reg.position = Vector3(0.9, 1.12, 2.85)
		add_child(reg)
	_register_light = OmniLight3D.new()
	_register_light.light_color = Color(0.3, 1.0, 0.4)
	_register_light.light_energy = 0.0
	_register_light.omni_range = 1.2
	_register_light.position = Vector3(0, 0.12, 0.08)
	reg.add_child(_register_light)
	# Body only, below the top, so the keypad on the green top gets the ray.
	_mark(reg, "register", Vector3(0.24, 0.1, 0.16), Vector3.ZERO)
	_build_keypad(reg)
	_slip = Node3D.new()
	_slip.name = "Slip"
	_slip.visible = false
	# On the centre machine's tray floor. TrayFloor top is y 0.505.
	_slip.position = Vector3(0.0, 0.512, 0.54)
	var slip_home: Node = _cabs[1] if _cabs.size() > 1 else self
	slip_home.add_child(_slip)
	CabinetBuilderScript.box(_slip, Vector3(0.18, 0.002, 0.1), Vector3.ZERO, CabinetBuilderScript.mat(Color(0.9, 0.86, 0.7)), "Paper")
	var sl := Label3D.new()
	sl.text = "4  1  8"
	sl.font_size = 64
	sl.pixel_size = 0.0018
	sl.position = Vector3(0, 0.02, 0)
	sl.rotation_degrees = Vector3(-90, 0, 0)
	sl.modulate = Color(0.15, 0.1, 0.08)
	_slip.add_child(sl)
	_mark(_slip, "slip", Vector3(0.22, 0.1, 0.14), Vector3.ZERO)


func _build_keypad(reg: Node3D) -> void:
	var pad := Node3D.new()
	pad.name = "TillKeypad"
	# Flat on the green top. +Z is the side that faces the hall door.
	pad.position = Vector3(0.0, 0.066, 0.015)
	reg.add_child(pad)
	var plate := MeshInstance3D.new()
	var plate_mesh := BoxMesh.new()
	plate_mesh.size = Vector3(0.1, 0.004, 0.09)
	plate.mesh = plate_mesh
	plate.position = Vector3(0.0, 0.0, 0.008)
	plate.material_override = CabinetBuilderScript.mat(Color(0.22, 0.18, 0.14), 0.62)
	pad.add_child(plate)
	var n := 1
	for r in 3:
		for c in 3:
			# Row 1 is toward the screen. 0 is toward the door.
			_till_key(pad, n, Vector3(-0.028 + float(c) * 0.028, 0.005, -0.016 + float(r) * 0.02))
			n += 1
	_till_key(pad, 0, Vector3(0.0, 0.005, -0.016 + 3.0 * 0.02))
	_code_label = Label3D.new()
	_code_label.name = "TillCode"
	_code_label.text = "---"
	_code_label.font_size = 64
	_code_label.pixel_size = 0.00055
	_code_label.position = Vector3(0.0, 0.1, -0.072)
	_code_label.modulate = Color(0.15, 0.2, 0.12)
	reg.add_child(_code_label)


func _till_key(pad: Node3D, digit: int, at: Vector3) -> void:
	var key := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.022, 0.006, 0.016)
	key.mesh = mesh
	key.position = at
	key.material_override = CabinetBuilderScript.mat(Color(0.62, 0.54, 0.34), 0.45)
	key.name = "Key_%d" % digit
	pad.add_child(key)
	var glyph := Label3D.new()
	glyph.text = str(digit)
	glyph.font_size = 48
	glyph.pixel_size = 0.00032
	glyph.position = Vector3(0, 0.005, 0)
	glyph.rotation_degrees = Vector3(-90, 0, 0)
	glyph.modulate = Color(0.12, 0.08, 0.04)
	key.add_child(glyph)
	_mark(key, "digit_%d" % digit, Vector3(0.024, 0.02, 0.018), Vector3(0, 0.012, 0))
	var key_body := key.get_node("Use_digit_%d" % digit) as StaticBody3D
	key_body.collision_layer = 2
	key_body.collision_mask = 0


func _at_till_front() -> bool:
	var reg := _named("Register") as Node3D
	if reg == null or _player == null:
		return false
	# The usable side faces the hall door. The other side is the back.
	var front := reg.global_transform.basis.z
	var to_player := _player.global_position - reg.global_position
	to_player.y = 0.0
	if to_player.length() < 0.05:
		return false
	return front.dot(to_player.normalized()) > 0.05


func _age_the_house() -> void:
	if _lounge:
		for name in ["Bar", "Floor", "BarTop"]:
			var mi := _named(name) as MeshInstance3D
			_dull_mesh(mi, 0.18)
		for i in 4:
			_dull_mesh(_named("Stool_%d" % i) as MeshInstance3D, 0.22)
		for post in _lounge.find_children("Post_*", "MeshInstance3D", true, false):
			_dull_mesh(post as MeshInstance3D, 0.2)
	for cab in _cabs:
		if cab is Node3D:
			for mi in (cab as Node3D).find_children("*", "MeshInstance3D", true, false):
				var mesh_node := mi as MeshInstance3D
				if str(mesh_node.name).begins_with("Cell_"):
					continue
				_dull_mesh(mesh_node, 0.28)


func _dull_mesh(mi: MeshInstance3D, amount: float) -> void:
	if mi == null:
		return
	var src := mi.get_active_material(0)
	if src is not StandardMaterial3D:
		return
	var m := (src as StandardMaterial3D).duplicate() as StandardMaterial3D
	m.albedo_color = m.albedo_color.darkened(amount)
	m.roughness = clampf(m.roughness + 0.18, 0.0, 1.0)
	mi.set_surface_override_material(0, m)


func _dress() -> void:
	for n in ["PaintPineapple", "PaintLeaf", "PaintCoconut", "PaperFlap", "PaperCurl", "WallpaperLeft"]:
		var junk: Node3D = _named(n)
		if junk:
			junk.visible = false
	_paper_the_walls()
	_build_house_line()
	_notebook_mesh = _named("Notebook")
	if _notebook_mesh:
		_mark(_notebook_mesh, "stool_note", Vector3(0.28, 0.16, 0.36), Vector3.ZERO)
	else:
		_notebook_on_floor()
	_mark_at(Vector3(-2.4, 0.55, 2.6), "stool_empty", Vector3(0.5, 0.8, 0.5), "StoolEmpty")


func _paper_the_walls() -> void:
	var paper := StandardMaterial3D.new()
	var path := ProjectSettings.globalize_path("res://art/seasons/paloma/wallpaper_lounge.png")
	var img := Image.load_from_file(path)
	if img:
		paper.albedo_texture = ImageTexture.create_from_image(img)
	else:
		paper.albedo_color = Color(0.62, 0.52, 0.38)
	paper.uv1_scale = Vector3(2.2, 1.6, 1.0)
	paper.roughness = 0.88
	paper.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	for n in ["WallpaperLeft", "WallLeft", "WallRight", "WallBack"]:
		var mesh_i: MeshInstance3D = _named(n) as MeshInstance3D
		if mesh_i:
			mesh_i.material_override = paper


func _build_house_line() -> void:
	## Framed payline on the wall — pineapple, leaf, coconut. Casino decor, not fruit blobs.
	var sign := Node3D.new()
	sign.name = "HouseLine"
	sign.position = Vector3(-6.78, 1.42, -0.55)
	sign.rotation_degrees = Vector3(0, 90, 0)
	add_child(sign)
	CabinetBuilderScript.box(sign, Vector3(1.02, 0.42, 0.05), Vector3.ZERO, CabinetBuilderScript.wood_mat(Color(0.32, 0.18, 0.08)), "Frame")
	CabinetBuilderScript.box(sign, Vector3(0.94, 0.34, 0.02), Vector3(0, 0, 0.02), CabinetBuilderScript.mat(Color(0.12, 0.08, 0.05)), "Back")
	var keys := ["P", "L", "C"]
	for i in 3:
		var mi := MeshInstance3D.new()
		var q := QuadMesh.new()
		q.size = Vector2(0.26, 0.26)
		mi.mesh = q
		mi.position = Vector3(-0.30 + float(i) * 0.30, 0.0, 0.04)
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_texture = load("res://art/seasons/paloma/sym_%s.png" % keys[i])
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
		mi.material_override = m
		mi.name = "Line_%s" % keys[i]
		sign.add_child(mi)
	_mark(sign, "house_line", Vector3(1.1, 0.5, 0.2), Vector3.ZERO)


func _spray_bird_on_wall() -> void:
	# Painted silhouette — a picture of the statue, not words.
	var g := Node3D.new()
	g.name = "GraffitiBird"
	g.position = Vector3(-5.35, 1.45, -0.2)
	g.rotation_degrees = Vector3(0, 90, 0)
	add_child(g)
	var paint := CabinetBuilderScript.mat(Color(0.45, 0.08, 0.08), 0.9)
	CabinetBuilderScript.sphere(g, 0.22, Vector3(0, 0.05, 0.02), paint, "Body")
	CabinetBuilderScript.sphere(g, 0.14, Vector3(0.22, 0.22, 0.02), paint, "Head")
	CabinetBuilderScript.box(g, Vector3(0.38, 0.07, 0.04), Vector3(0.48, 0.18, 0.03), paint, "Beak")
	CabinetBuilderScript.box(g, Vector3(0.32, 0.08, 0.04), Vector3(-0.18, 0.08, 0.03), paint, "Wing")


func _peeling_paper() -> void:
	var paper := Node3D.new()
	paper.name = "Wallpaper"
	paper.position = Vector3(-5.28, 1.15, 1.55)
	paper.rotation_degrees = Vector3(0, 90, 0)
	add_child(paper)
	# Fruit painted on the plaster, hidden until the flap drops.
	var gold := CabinetBuilderScript.mat(Color(0.9, 0.62, 0.15), 0.4)
	var leaf := CabinetBuilderScript.mat(Color(0.28, 0.5, 0.16), 0.5)
	var brown := CabinetBuilderScript.mat(Color(0.55, 0.32, 0.14), 0.5)
	CabinetBuilderScript.sphere(paper, 0.09, Vector3(-0.22, 0.0, 0.03), gold, "PaintPine")
	CabinetBuilderScript.cone(paper, 0.07, 0.18, Vector3(0.0, 0.02, 0.03), leaf, "PaintLeaf")
	CabinetBuilderScript.sphere(paper, 0.09, Vector3(0.22, 0.0, 0.03), brown, "PaintCoco")
	_paper_flap = Node3D.new()
	_paper_flap.name = "Flap"
	paper.add_child(_paper_flap)
	var faded := CabinetBuilderScript.mat(Color(0.72, 0.58, 0.4), 0.85)
	CabinetBuilderScript.box(_paper_flap, Vector3(0.85, 0.55, 0.015), Vector3(0, 0, 0.05), faded, "Sheet")
	CabinetBuilderScript.box(_paper_flap, Vector3(0.22, 0.12, 0.01), Vector3(0.28, -0.28, 0.08), faded, "Curl")
	_paper_flap.get_node("Curl").rotation_degrees = Vector3(35, 0, -12)
	_mark(paper, "wallpaper", Vector3(0.95, 0.7, 0.25), Vector3.ZERO)


func _notebook_on_floor() -> void:
	_notebook_mesh = Node3D.new()
	_notebook_mesh.name = "Notebook"
	_notebook_mesh.position = Vector3(-0.85, 0.06, 2.55)
	_notebook_mesh.rotation_degrees = Vector3(0, 22, 0)
	add_child(_notebook_mesh)
	CabinetBuilderScript.box(_notebook_mesh, Vector3(0.2, 0.03, 0.28), Vector3.ZERO, CabinetBuilderScript.mat(Color(0.28, 0.12, 0.08), 0.6), "Cover")
	CabinetBuilderScript.box(_notebook_mesh, Vector3(0.18, 0.02, 0.26), Vector3(0, 0.02, 0), CabinetBuilderScript.mat(Color(0.86, 0.8, 0.68), 0.7), "Pages")
	_mark(_notebook_mesh, "stool_note", Vector3(0.28, 0.16, 0.36), Vector3.ZERO)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var cross := ColorRect.new()
	cross.set_anchors_preset(Control.PRESET_CENTER)
	cross.offset_left = -2
	cross.offset_right = 2
	cross.offset_top = -2
	cross.offset_bottom = 2
	cross.color = Color(0.95, 0.9, 0.8, 0.7)
	cross.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(cross)
	_hint = Label.new()
	_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hint.offset_top = -132
	_hint.offset_bottom = -48
	_hint.offset_left = -640
	_hint.offset_right = 640
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD
	_hint.add_theme_font_size_override("font_size", 32)
	_hint.add_theme_color_override("font_color", Color(0.92, 0.88, 0.8))
	_hint.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03))
	_hint.add_theme_constant_override("outline_size", 5)
	layer.add_child(_hint)
	_inv_label = Label.new()
	_inv_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_inv_label.offset_top = -44
	_inv_label.offset_bottom = -6
	_inv_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_inv_label.add_theme_font_size_override("font_size", 24)
	_inv_label.add_theme_color_override("font_color", Color(0.95, 0.88, 0.7))
	_inv_label.add_theme_constant_override("outline_size", 5)
	_inv_label.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03))
	layer.add_child(_inv_label)
	EscapeInventory.changed.connect(_refresh_inv)
	_refresh_inv()
	_wake_label = Label.new()
	_wake_label.set_anchors_preset(Control.PRESET_CENTER)
	_wake_label.offset_left = -420
	_wake_label.offset_right = 420
	_wake_label.offset_top = -40
	_wake_label.offset_bottom = 40
	_wake_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wake_label.add_theme_font_size_override("font_size", 28)
	_wake_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.82))
	_wake_label.add_theme_constant_override("outline_size", 8)
	_wake_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	layer.add_child(_wake_label)
	_stuck_label = Label.new()
	_stuck_label.visible = false
	_stuck_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_stuck_label.offset_top = 16
	_stuck_label.offset_bottom = 70
	_stuck_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stuck_label.add_theme_font_size_override("font_size", 16)
	_stuck_label.add_theme_color_override("font_color", Color(0.85, 0.78, 0.65))
	layer.add_child(_stuck_label)
	_build_pad(layer)
	_complete = ColorRect.new()
	_complete.set_anchors_preset(Control.PRESET_FULL_RECT)
	_complete.color = Color(0.02, 0.015, 0.01, 0.0)
	_complete.visible = false
	_complete.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(_complete)
	var done := Label.new()
	done.name = "DoneText"
	done.set_anchors_preset(Control.PRESET_CENTER)
	done.offset_left = -480
	done.offset_right = 480
	done.offset_top = -60
	done.offset_bottom = 60
	done.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	done.add_theme_font_size_override("font_size", 26)
	done.add_theme_color_override("font_color", Color(0.92, 0.86, 0.74))
	done.text = "Room 01 clear.\nThe lobby is still sealed."
	_complete.add_child(done)
	_blink = ColorRect.new()
	_blink.set_anchors_preset(Control.PRESET_FULL_RECT)
	_blink.color = Color(0, 0, 0, 0)
	_blink.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_blink.visible = false
	layer.add_child(_blink)
	_narration = Label.new()
	_narration.visible = false
	_narration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_narration.set_anchors_preset(Control.PRESET_CENTER)
	_narration.offset_left = -560
	_narration.offset_right = 560
	_narration.offset_top = -80
	_narration.offset_bottom = 80
	_narration.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_narration.autowrap_mode = TextServer.AUTOWRAP_WORD
	_narration.add_theme_font_size_override("font_size", 36)
	_narration.add_theme_color_override("font_color", Color(0.94, 0.9, 0.82))
	_narration.add_theme_constant_override("outline_size", 8)
	_narration.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	layer.add_child(_narration)


func _blink_awake() -> void:
	_busy = true
	_blink.visible = true
	_blink.color.a = 1.0
	_narrate("Dark.")
	var tw := create_tween()
	tw.tween_interval(1.8)
	tw.tween_property(_blink, "color:a", 0.42, 1.6)
	tw.tween_callback(func() -> void: _narrate("A slit of light. You do not know the room."))
	tw.tween_interval(1.8)
	tw.tween_property(_blink, "color:a", 1.0, 1.3)
	tw.tween_callback(func() -> void: _narrate("Dark again."))
	tw.tween_interval(1.6)
	tw.tween_property(_blink, "color:a", 0.0, 2.4)
	tw.tween_callback(func() -> void:
		_blink.visible = false
		_busy = false
		_narrate("You are on the floor. The house is closed.")
		_say("Something on that machine is loose.")
		_start_bed()
	)
	tw.tween_interval(4.2)
	tw.tween_callback(func() -> void:
		if _narration:
			_narration.visible = false
	)


func _narrate(line: String) -> void:
	if _narration == null:
		return
	_narration.text = line
	_narration.visible = true
	_narration.modulate.a = 1.0


func _load_wav(path: String, looped: bool) -> AudioStreamWAV:
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.size() < 80:
		return null
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 44100
	stream.stereo = false
	stream.data = bytes.slice(78)
	if looped:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = int(stream.data.size() / 2)
	return stream


func _one_shot(path: String, db: float) -> void:
	var stream := _load_wav(path, false)
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = db
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()


func _dim_for_fuse() -> void:
	if _lamp:
		_lamp.light_energy = 0.18
	if _fill:
		_fill.light_energy = 0.04
	if _env:
		_env.ambient_light_energy = 0.1
	if _flicker:
		_flicker.light_energy = 0.0


func _start_bed() -> void:
	if _bed != null and _bed.playing:
		return
	var stream := _load_wav("res://audio/lounge/bed.wav", true)
	if stream == null:
		return
	_bed = AudioStreamPlayer.new()
	_bed.name = "RoomBed"
	_bed.stream = stream
	_bed.volume_db = -18.0
	add_child(_bed)
	_bed_pending = true


func _build_pad(layer: CanvasLayer) -> void:
	_pad = Panel.new()
	_pad.visible = false
	_pad.set_anchors_preset(Control.PRESET_CENTER)
	_pad.offset_left = -140
	_pad.offset_right = 140
	_pad.offset_top = -200
	_pad.offset_bottom = 200
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.07, 0.05, 0.95)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.4, 0.32, 0.2)
	_pad.add_theme_stylebox_override("panel", sb)
	layer.add_child(_pad)
	_pad_display = Label.new()
	_pad_display.position = Vector2(20, 16)
	_pad_display.size = Vector2(240, 40)
	_pad_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pad_display.add_theme_font_size_override("font_size", 28)
	_pad_display.text = "---"
	_pad.add_child(_pad_display)
	var n := 1
	for r in 3:
		for c in 3:
			_pad_btn(Vector2(30 + c * 75, 70 + r * 70), str(n), n)
			n += 1
	_pad_btn(Vector2(105, 280), "0", 0)
	var close := Button.new()
	close.text = "Close"
	close.position = Vector2(90, 350)
	close.size = Vector2(100, 32)
	close.pressed.connect(func() -> void:
		_pad.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	)
	_pad.add_child(close)


func _pad_btn(pos: Vector2, text: String, digit: int) -> void:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = Vector2(64, 56)
	b.pressed.connect(func() -> void: _pad_digit(digit))
	_pad.add_child(b)


func _pad_digit(d: int) -> void:
	if _pad_value.length() >= 3:
		_pad_value = ""
	_pad_value += str(d)
	_show_code(_pad_value)
	if _pad_value == "418":
		_flags["code_ok"] = true
		if not _flags["has_key"]:
			_flags["has_key"] = true
			EscapeInventory.add_item("key", "House key")
			_say("The drawer kicks. A house key.")
			_narrate("The drawer kicks. A house key.")
		_pad.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_persist()
		return
	if _pad_value.length() == 3:
		var wrong := _pad_value
		_say("That is not the dawn count.")
		_narrate("That is not the dawn count.")
		var tw := create_tween()
		tw.tween_interval(1.1)
		tw.tween_callback(func() -> void:
			if _pad_value != wrong or _flags["has_key"]:
				return
			_pad_value = ""
			_show_code("---")
			if _narration and _narration.text == "That is not the dawn count.":
				_narration.visible = false
		)


func _show_code(text: String) -> void:
	if _pad_display:
		_pad_display.text = text
	if _code_label:
		_code_label.text = text


func _pad_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_0 and event.keycode <= KEY_9:
			_pad_digit(event.keycode - KEY_0)
		elif event.keycode >= KEY_KP_0 and event.keycode <= KEY_KP_9:
			_pad_digit(event.keycode - KEY_KP_0)
		elif event.keycode == KEY_ESCAPE:
			_pad.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _refresh_inv() -> void:
	var parts: PackedStringArray = []
	for i in EscapeInventory.slots.size():
		var s: Dictionary = EscapeInventory.slots[i]
		var mark := ">" if i == EscapeInventory.selected else " "
		var n: int = int(s.get("count", 1))
		var t: String = str(s.get("label", ""))
		if n > 1:
			t += " ×%d" % n
		parts.append("%s%d %s" % [mark, i + 1, t])
	_inv_label.text = "   ".join(parts) if parts.size() else ""


func _paint_abandoned(room: Node) -> void:
	var floor_m := StandardMaterial3D.new()
	floor_m.albedo_color = Color(0.22, 0.12, 0.07)
	floor_m.roughness = 0.85
	var wall_m := StandardMaterial3D.new()
	wall_m.albedo_color = Color(0.38, 0.3, 0.22)
	wall_m.roughness = 0.9
	var thatch_m := StandardMaterial3D.new()
	thatch_m.albedo_color = Color(0.28, 0.16, 0.08)
	thatch_m.roughness = 0.9
	var ocean_m := StandardMaterial3D.new()
	ocean_m.albedo_color = Color(0.04, 0.06, 0.1)
	ocean_m.roughness = 0.4
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


func _wood_mat() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	var path := "res://art/seasons/paloma/wood.png"
	if ResourceLoader.exists(path):
		m.albedo_texture = load(path)
	else:
		var img := Image.load_from_file(ProjectSettings.globalize_path(path))
		if img:
			m.albedo_texture = ImageTexture.create_from_image(img)
	m.uv1_scale = Vector3(1.6, 0.45, 1.0)
	m.roughness = 0.72
	return m


func _board_the_window() -> void:
	for n in ["WindowBoard_0", "WindowBoard_1", "WindowBoard_2"]:
		var old: Node3D = _named(n)
		if old:
			old.visible = false
	var wood := _wood_mat()
	var group := Node3D.new()
	group.name = "WindowBoards"
	add_child(group)
	var ocean: Node3D = _named("Ocean")
	if ocean:
		group.global_position = ocean.global_position + Vector3(0, 0, 0.12)
	else:
		group.position = Vector3(0, 1.4, -4.7)
	# Overlapping planks. The notice is behind the wood, not readable until taken.
	_notice = Node3D.new()
	_notice.name = "WindowNotice"
	_notice.position = Vector3(0.1, 0.02, -0.1)
	group.add_child(_notice)
	var sheet := MeshInstance3D.new()
	var paper := QuadMesh.new()
	paper.size = Vector2(0.62, 0.36)
	sheet.mesh = paper
	var pm := StandardMaterial3D.new()
	pm.albedo_color = Color(0.86, 0.8, 0.66)
	pm.roughness = 0.9
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sheet.material_override = pm
	sheet.name = "Sheet"
	_notice.add_child(sheet)
	var headline := Label3D.new()
	headline.text = "PALOMA HOUSE CLOSED\nSTAFF LEFT THE TILL."
	headline.font_size = 42
	headline.pixel_size = 0.00115
	headline.position = Vector3(0, 0, 0.004)
	headline.modulate = Color(0.12, 0.08, 0.05)
	headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	headline.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	headline.no_depth_test = false
	headline.alpha_cut = Label3D.ALPHA_CUT_OPAQUE_PREPASS
	_notice.add_child(headline)
	var plank_y := [-0.50, -0.30, -0.10, 0.10, 0.30, 0.50]
	for i in plank_y.size():
		var plank := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(3.2, 0.26, 0.08)
		plank.mesh = mesh
		plank.position = Vector3(0.0, plank_y[i], 0.0)
		plank.rotation_degrees = Vector3(0, 0, -0.5 + float(i) * 0.2)
		plank.material_override = wood
		plank.name = "Plank_%d" % i
		group.add_child(plank)
		_add_mesh_collision(plank)
	# In front of the planks, so a look at the boards can pull the hidden sheet.
	_mark(group, "boards", Vector3(3.0, 1.15, 0.16), Vector3(0.0, 0.0, 0.14))
	var ocean_mesh: MeshInstance3D = ocean as MeshInstance3D
	if ocean_mesh:
		_add_mesh_collision(ocean_mesh)


func _collide_room() -> void:
	var names := [
		"Bar", "BarFront", "BarTop", "FootRail",
		"WallLeft", "WallRight", "WallBack",
		"HallDoor", "DoorFrame",
		"Register", "RegisterDrawer",
	]
	for n in names:
		var mi: MeshInstance3D = _named(n) as MeshInstance3D
		if mi:
			_add_mesh_collision(mi)
	for i in 4:
		var stool: Node3D = _named("Stool_%d" % i)
		if stool:
			_add_box_collision(stool, Vector3(0.46, 0.58, 0.46), Vector3(0, 0.28, 0))
	for post in _lounge.find_children("Post_*", "MeshInstance3D", true, false):
		_add_mesh_collision(post as MeshInstance3D)


func _add_mesh_collision(mi: MeshInstance3D) -> void:
	if mi == null or mi.get_node_or_null("Solid") != null:
		return
	var aabb: AABB = mi.get_aabb()
	if aabb.size.length() < 0.04:
		return
	_add_box_collision(mi, aabb.size, aabb.position + aabb.size * 0.5)


func _add_box_collision(node: Node3D, size: Vector3, offset: Vector3) -> void:
	if node.get_node_or_null("Solid") != null:
		return
	var body := StaticBody3D.new()
	body.name = "Solid"
	var col := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	col.shape = sh
	col.position = offset
	body.add_child(col)
	node.add_child(body)


func _mark(node: Node3D, id: String, size: Vector3, pos: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = "Use_%s" % id
	body.set_meta("use_id", id)
	var col := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	col.shape = sh
	col.position = pos
	body.add_child(col)
	node.add_child(body)


func _mark_at(world: Vector3, id: String, size: Vector3, name: String) -> void:
	var n := Node3D.new()
	n.name = name
	n.position = world
	add_child(n)
	_mark(n, id, size, Vector3.ZERO)


func _update_hover() -> void:
	_hover_id = ""
	_hover_node = null
	var from: Vector3 = _cam.global_position
	var to: Vector3 = from + (-_cam.global_transform.basis.z) * 3.4
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.exclude = [_player.get_rid()]
	q.collision_mask = 0xFFFFFFFF
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit:
		var n: Node = hit.get("collider")
		while n:
			if n.has_meta("use_id"):
				_hover_id = str(n.get_meta("use_id"))
				_hover_node = n
				break
			n = n.get_parent()
	var hover_hint := _hint_for(_hover_id)
	if hover_hint != "":
		_hint.text = hover_hint
	elif _hover_id == "":
		_hint.text = _last_earned
	_stuck_label.text = "H — last thing you learned\n%s" % _last_earned
	_glow_bird(_hover_id == "bird" and not _flags["bird_turned"])


func _glow_bird(on: bool) -> void:
	if _bird_spin == null:
		return
	for mi in _bird_spin.find_children("*", "MeshInstance3D", true, false):
		var mesh_i := mi as MeshInstance3D
		var m: StandardMaterial3D = mesh_i.material_override as StandardMaterial3D
		if m == null:
			continue
		m.emission_enabled = on
		if on:
			m.emission = Color(1.0, 0.82, 0.45)
			m.emission_energy_multiplier = 0.25
		else:
			m.emission_energy_multiplier = 0.0


func _hint_for(id: String) -> String:
	match id:
		"door":
			if _flags["door_open"]:
				return "The hall is open"
			if EscapeInventory.has_item("key"):
				return "Use the house key"
			return "The door is chained"
		"bird":
			if _flags["bird_turned"]:
				return "The statue is spent"
			return "Hold and drag to turn the bird"
		"setter":
			if _flags["jackpot"]:
				return "The window already paid"
			if int(_flags["coins_in_tray"]) < 3:
				return "The tray is hungry"
			return "Set the window"
		"reel_0", "reel_1", "reel_2":
			if int(_flags["coins_in_tray"]) < 3:
				return "Feed the tray first"
			return "Change this symbol"
		"jammed":
			if _flags["jackpot"]:
				return "A spare slip in the panel"
			return "Hopper jammed"
		"register":
			if _flags["has_key"]:
				return "The drawer is empty"
			if _flags["jackpot"] and _flags["fuse_in"]:
				return "Enter the dawn count"
			if _flags["jackpot"]:
				return "Screen dark — something pops in the roof"
			return "Till is dead"
		"lantern":
			if _flags["fuse"]:
				return "The socket is empty"
			return "Unscrew the flickering lantern"
		"stool_note":
			if _flags["notebook"]:
				return ""
			return "A notebook on the floor"
		"stool_empty":
			return "It wobbles. Nothing."
		"house_line":
			return "The house line: pineapple, leaf, coconut"
		"plinth":
			if _flags["flashlight"]:
				return "The sign is off"
			return "Pry the sign"
		"boards":
			if _flags["notice"]:
				return "The boards are bare"
			return "The window is boarded up"
		"coin":
			return "Pick up a brass coin"
		"slip":
			if _flags["jackpot"]:
				return "A pay slip  4 1 8"
			return ""
		_:
			if id.begins_with("digit_"):
				return "A key on the front of the till"
			return ""


func _use() -> void:
	if _busy or _hover_id == "":
		return
	match _hover_id:
		"door":
			_use_door()
		"bird":
			_nudge_bird()
		"setter":
			_use_tray()
		"reel_0":
			_cycle_reel(0)
		"reel_1":
			_cycle_reel(1)
		"reel_2":
			_cycle_reel(2)
		"jammed":
			if _flags["jackpot"]:
				_say("A torn corner. The last digit is 8.")
			else:
				_say("Hopper jammed.")
		"register":
			_use_register()
		"lantern":
			if not _flags["fuse"]:
				_flags["fuse"] = true
				EscapeInventory.add_item("fuse", "Fuse")
				_flicker.light_energy = 0.0
				_dim_for_fuse()
				_say("A warm fuse. The light dies.")
				_persist()
		"stool_note":
			if not _flags["notebook"]:
				_flags["notebook"] = true
				EscapeInventory.add_item("notebook", "Notebook")
				if _notebook_mesh:
					_notebook_mesh.visible = false
				_say("Dawn count is not luck. Set the house line on the wall. Feed the till after the window pays.")
				_narrate("Dawn count is not luck. Set the house line. Feed the till after the window pays.")
				_persist()
		"stool_empty":
			_say("Dust and a dead match.")
		"house_line":
			var first_read := not bool(_flags["wallpaper"])
			_flags["wallpaper"] = true
			_say("The house line: pineapple, leaf, coconut.")
			_narrate("Pineapple. Leaf. Coconut.")
			if first_read:
				_one_shot("res://audio/lounge/house_line.wav", -4.0)
			_persist()
		"plinth":
			if not _flags["flashlight"]:
				_flags["flashlight"] = true
				EscapeInventory.add_item("light", "Flashlight")
				_say("A dead flashlight. The batteries still tick.")
				_persist()
		"boards":
			_take_notice()
		"coin":
			_pickup_coin()
		"slip":
			if _flags["jackpot"]:
				_say("4 1 8")
		_:
			if _hover_id.begins_with("digit_"):
				_press_digit(int(_hover_id.substr(6)))


func _use_door() -> void:
	if _flags["door_open"]:
		_finish()
		return
	if EscapeInventory.has_item("key"):
		EscapeInventory.take("key")
		_flags["door_open"] = true
		if _chain:
			_chain.visible = false
		var lock := _named("Padlock")
		if lock:
			lock.visible = false
		var tw := create_tween()
		tw.tween_property(_door, "rotation_degrees:y", -75.0, 0.8)
		_one_shot("res://audio/lounge/chain.wav", 4.0)
		_say("The chain drops.")
		_persist()
		tw.tween_callback(_finish)
	else:
		_say("House key is with the till. Till is dead.")


func _nudge_bird() -> void:
	if _flags["bird_turned"] or _bird_spin == null or _busy:
		return
	_busy = true
	var tw := create_tween()
	tw.tween_property(_bird_spin, "rotation:y", _bird_spin.rotation.y + deg_to_rad(45.0), 0.35)
	tw.tween_callback(func() -> void:
		_busy = false
		_finish_turn()
	)


func _finish_turn() -> void:
	if _flags["bird_turned"] or _bird_spin == null:
		return
	var ang: float = absf(wrapf(_bird_spin.rotation.y, -PI, PI))
	if ang > deg_to_rad(150.0):
		_dump_coins()
	else:
		_one_shot("res://audio/lounge/pin.wav", -6.0)
		_say("It turns on the pin. Keep going.")


func _pull_paper() -> void:
	if _flags["wallpaper"] or _paper_flap == null:
		return
	_flags["wallpaper"] = true
	var tw := create_tween()
	tw.tween_property(_paper_flap, "position:y", -0.7, 0.5)
	tw.parallel().tween_property(_paper_flap, "rotation_degrees:z", 16.0, 0.5)
	_say("Painted fruit under the paper: pineapple, leaf, coconut.")
	_persist()


func _dump_coins() -> void:
	_flags["bird_turned"] = true
	_flags["coins_dumped"] = true
	_one_shot("res://audio/lounge/coins.wav", -2.0)
	_say("The hopper coughs. Brass on the floor.")
	_spawn_coins(7)
	_persist()
	_busy = false


func _spawn_coins(count: int) -> void:
	var cab: Node3D = _cabs[0]
	var origin := cab.global_position
	for i in count:
		var coin := StaticBody3D.new()
		coin.name = "Coin_%d" % i
		coin.set_meta("use_id", "coin")
		var mi := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.07
		mesh.bottom_radius = 0.07
		mesh.height = 0.014
		mi.mesh = mesh
		mi.position.y = 0.01
		mi.material_override = CabinetBuilderScript.mat(Color(0.82, 0.62, 0.22), 0.32, Color(0.75, 0.5, 0.12), 0.35)
		coin.add_child(mi)
		var col := CollisionShape3D.new()
		var sh := CylinderShape3D.new()
		sh.radius = 0.11
		sh.height = 0.12
		col.shape = sh
		col.position.y = 0.06
		coin.add_child(col)
		var col_i := i % 4
		var row := int(i / 4.0)
		coin.position = origin + Vector3(-0.40 + float(col_i) * 0.26, 0.03, 1.45 + float(row) * 0.32)
		add_child(coin)


func _take_notice() -> void:
	if _notice == null or bool(_flags["notice"]):
		_say("Nothing left behind the boards.")
		return
	_flags["notice"] = true
	_busy = true
	var from_pos := _notice.global_position
	var hold := _cam.global_position - _cam.global_transform.basis.z * 0.85
	hold.y = _cam.global_position.y - 0.08
	var tw := create_tween()
	tw.tween_method(func(t: float) -> void:
		if _notice == null:
			return
		_notice.global_position = from_pos.lerp(hold, t)
		if _cam:
			_notice.look_at(_cam.global_position, Vector3.UP)
			_notice.rotate_object_local(Vector3.UP, PI)
	, 0.0, 1.0, 0.55)
	tw.tween_interval(1.4)
	tw.tween_callback(func() -> void:
		var body := _notice.get_node_or_null("Use_boards")
		if body:
			body.queue_free()
		_notice.visible = false
		_busy = false
		_say("PALOMA HOUSE CLOSED — STAFF LEFT THE TILL.")
		_narrate("Paloma House closed. Staff left the till.")
		_persist()
	)


func _pickup_coin() -> void:
	var c := _hover_node
	if c == null or str(c.get_meta("use_id", "")) != "coin":
		return
	_hover_node = null
	c.queue_free()
	EscapeInventory.add_item("coin", "Brass coin")
	_say("A brass coin.")
	_persist()


func _use_tray() -> void:
	if _flags["jackpot"]:
		_say("The window already paid.")
		return
	if EscapeInventory.count_of("coin") <= 0:
		_say("You have nothing to feed it.")
		return
	if int(_flags["coins_in_tray"]) >= 3:
		_say("The tray is full. Set the window.")
		return
	EscapeInventory.take("coin")
	_flags["coins_in_tray"] = int(_flags["coins_in_tray"]) + 1
	_say("Coin in the tray. %d of 3." % int(_flags["coins_in_tray"]))
	_persist()


func _cycle_reel(idx: int) -> void:
	if int(_flags["coins_in_tray"]) < 3:
		_say("Feed the tray first.")
		return
	if _flags["jackpot"]:
		return
	var cur: String = str(_reel_ids[idx])
	var at: int = REEL_CYCLE.find(cur)
	_reel_ids[idx] = REEL_CYCLE[(at + 1) % REEL_CYCLE.size()]
	var cab: Node3D = _cabs[1]
	var cell: MeshInstance3D = cab.find_child("Cell_%d_1" % (idx + 1), true, false) as MeshInstance3D
	if cell:
		_set_reel_tex(cell, str(_reel_ids[idx]))
	_one_shot("res://audio/lounge/click.wav", -8.0)
	if _reel_ids[0] == JACKPOT[0] and _reel_ids[1] == JACKPOT[1] and _reel_ids[2] == JACKPOT[2]:
		_do_jackpot()


func _do_jackpot() -> void:
	_flags["jackpot"] = true
	_slip.visible = true
	_one_shot("res://audio/lounge/till.wav", -4.0)
	_say("The window pays. A slip in the tray. The till clicks.")
	_narrate("A slip in the tray. 4 1 8.")
	_persist()


func _light_the_screen() -> void:
	if _register_light:
		_register_light.light_energy = 1.2
	var screen := _named("RegisterScreen") as MeshInstance3D
	if screen == null:
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.45, 0.22)
	mat.emission_enabled = true
	mat.emission = Color(0.25, 0.95, 0.4)
	mat.emission_energy_multiplier = 1.6
	screen.material_override = mat


func _press_digit(d: int) -> void:
	if not _at_till_front():
		_say("The keypad is on the other side of the till.")
		return
	if _flags["has_key"]:
		_say("The drawer is empty.")
		return
	if not _flags["jackpot"] or not _flags["fuse_in"]:
		_say("The keypad is dead.")
		return
	_one_shot("res://audio/lounge/click.wav", -10.0)
	_pad_digit(d)


func _use_register() -> void:
	if not _at_till_front():
		_say("The keypad is on the other side of the till.")
		return
	if _flags["has_key"]:
		_say("The drawer is empty.")
		return
	if not _flags["jackpot"]:
		_say("Till is dead.")
		return
	if not _flags["fuse_in"]:
		if EscapeInventory.has_item("fuse"):
			EscapeInventory.take("fuse")
			_flags["fuse_in"] = true
			_light_the_screen()
			if _code_label:
				_code_label.modulate = Color(0.7, 1.0, 0.75)
				_code_label.text = "---"
			_say("The screen coughs green. The keypad is on the till.")
			_persist()
		else:
			_say("Screen dark. Something still pops in the roof.")
		return
	_say("Enter the dawn count on the till.")


func _set_reel_tex(mi: MeshInstance3D, sym: String) -> void:
	var path := "res://art/seasons/paloma/sym_%s.png" % sym
	var mat: StandardMaterial3D = mi.material_override as StandardMaterial3D
	if mat == null:
		mat = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mi.material_override = mat
	if ResourceLoader.exists(path):
		mat.albedo_texture = load(path)


func _say(msg: String) -> void:
	_last_earned = msg
	_hint.text = msg
	_stuck_label.text = "H — last thing you learned\n%s" % _last_earned


func _persist() -> void:
	if not Save.progress.has("escape"):
		Save.progress["escape"] = {}
	var esc: Dictionary = Save.progress["escape"]
	esc["room_01"] = _flags.duplicate()
	esc["room_01_items"] = EscapeInventory.slots.duplicate(true)
	esc["room_01_reels"] = _reel_ids.duplicate()
	Save.progress["escape"] = esc
	Save.write_disk()


func _restore_progress() -> void:
	if not Save.progress.has("escape"):
		return
	var esc: Dictionary = Save.progress["escape"]
	if not esc.has("room_01"):
		return
	var saved: Dictionary = esc["room_01"]
	for k in _flags.keys():
		if not saved.has(k):
			continue
		if k == "coins_in_tray":
			_flags[k] = int(saved[k])
		else:
			_flags[k] = bool(saved[k])
	if esc.has("room_01_items"):
		EscapeInventory.slots = (esc["room_01_items"] as Array).duplicate(true)
		EscapeInventory.changed.emit()
	if esc.has("room_01_reels"):
		var reels: Array = esc["room_01_reels"]
		if reels.size() == 3:
			_reel_ids = reels.duplicate()
	_apply_saved_world()


func _apply_saved_world() -> void:
	if bool(_flags["bird_turned"]) and _bird_spin:
		_bird_spin.rotation.y = PI
	if bool(_flags["coins_dumped"]):
		var left := 7 - EscapeInventory.count_of("coin") - int(_flags["coins_in_tray"])
		if left > 0:
			_spawn_coins(left)
	_show_saved_reels()
	if bool(_flags["jackpot"]) and _slip:
		_slip.visible = true
	if bool(_flags["notebook"]) and _notebook_mesh:
		_notebook_mesh.visible = false
	if bool(_flags["notice"]) and _notice:
		_notice.visible = false
	if bool(_flags["fuse"]):
		_dim_for_fuse()
	if bool(_flags["fuse_in"]):
		_light_the_screen()
	if bool(_flags["door_open"]):
		if _chain:
			_chain.visible = false
		var lock := _named("Padlock")
		if lock:
			lock.visible = false
		if _door:
			_door.rotation_degrees.y = -75.0
	if bool(_flags["cleared"]) and _complete:
		_complete.visible = true
		_complete.color.a = 0.92


func _show_saved_reels() -> void:
	if _cabs.size() < 2:
		return
	var cab: Node3D = _cabs[1]
	for i in 3:
		var cell: MeshInstance3D = cab.find_child("Cell_%d_1" % (i + 1), true, false) as MeshInstance3D
		if cell:
			_set_reel_tex(cell, str(_reel_ids[i]))


func _finish() -> void:
	if _flags["cleared"]:
		return
	_flags["cleared"] = true
	_persist()
	_complete.visible = true
	_complete.color.a = 0.0
	var tw := create_tween()
	tw.tween_property(_complete, "color:a", 0.92, 1.2)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
