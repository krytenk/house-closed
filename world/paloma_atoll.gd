extends Node3D
## Paloma Atoll diorama — 3D objects from the locked visual refs. No photo billboards.

const RING := 9.4
const TILE_ICON := {
	"PORCH": "hibiscus",
	"BUNGALOW": "house",
	"PALM_PATH": "palm",
	"BUILD_A": "hammer",
	"MARINA_DOOR": "sail",
	"GUEST_BENCH": "star",
	"BEACH": "shell",
	"POKER_DOOR": "star",
	"BUILD_B": "hammer",
	"WILDLIFE": "shell",
	"LANTERN_PATH": "lantern",
	"SLOTS_DOOR": "fruit",
	"CRANK": "wheel",
	"SPLASH": "splash",
	"BUILD_C": "hammer",
	"ROULETTE_DOOR": "star",
	"COCONUT_GROVE": "coconut",
	"FRIEND_DOCK": "anchor",
	"BUILD_D": "hammer",
	"LOOKOUT": "star",
	"NIGHTCLUB_DOOR": "lantern",
	"BUILD_E": "hammer",
	"SPA_PATH": "hibiscus",
	"BUILD_F": "hammer",
}

var _animating: bool = false
var _tile_nodes: Array = []
var _cam_boost: float = 0.0
var _surf: AudioStreamPlayer
var _shot_frames: int = 0
var _shot_path: String = ""
var _walk_cam: bool = false


func _ready() -> void:
	add_to_group("paloma_island")
	RenderingServer.set_default_clear_color(Color(0.45, 0.78, 0.86))
	_build()
	$Board.token_tile = int(Save.progress.get("token_tile", 0))
	$Token.position = _tile_pos($Board.token_tile)
	_build_player_token()
	Game._set_hud_visible(true)
	_play_bed()
	_shot_path = OS.get_environment("PALM_SHOT")
	set_process(true)


func _exit_tree() -> void:
	Game._set_hud_visible(false)
	if _surf:
		_surf.stop()


func _process(delta: float) -> void:
	if _shot_path != "":
		_shot_frames += 1
		if _shot_frames == 20:
			var img: Image = get_viewport().get_texture().get_image()
			img.save_png(_shot_path)
			print("PALM_SHOT ", _shot_path, " ", img.get_width(), "x", img.get_height())
			get_tree().quit()
			return
	_follow_cam(delta)
	_pulse_current()
	if not _animating and Input.is_action_just_pressed("walk"):
		try_walk()
	if Input.is_action_just_pressed("ui_cancel"):
		Game.goto("pause")
	if Input.is_action_just_pressed("ui_focus_next"):
		_walk_cam = not _walk_cam
	if Game.hud and Game.hud.has_method("set_enter"):
		var tile: Dictionary = $Board.tile_at($Board.token_tile)
		var tap: String = str(tile.get("tap", ""))
		var lab: String = str(tile.get("label", tap)).to_upper()
		if tap == "":
			Game.hud.call("set_enter", "")
		elif lab != "":
			Game.hud.call("set_enter", lab)
		else:
			Game.hud.call("set_enter", Game.text("enter"))


func try_walk() -> Dictionary:
	if _animating:
		return {"ok": false, "busy": true}
	var start: int = $Board.token_tile
	var r: Dictionary = $Board.walk()
	if not bool(r.get("ok", false)):
		return r
	_animating = true
	Game.last_die = int(r.get("die", 1))
	if Game.hud and Game.hud.has_method("show_die"):
		Game.hud.call("show_die", Game.last_die)
	Game.play_sfx("click")
	var steps: int = int(r.get("steps", 1))
	var dest: int = $Board.token_tile
	for k in steps:
		var idx: int = (start + k + 1) % 24
		await _hop_to(idx)
	$Token.position = _tile_pos(dest)
	_animating = false
	Game.play_sfx("click")
	return r


func try_enter() -> void:
	if _animating:
		return
	$Board.tap_current()


func _hop_to(idx: int) -> void:
	var start_p: Vector3 = $Token.position
	var end_p: Vector3 = _tile_pos(idx)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_method(_hop_sample.bind(start_p, end_p), 0.0, 1.0, 0.22)
	await tw.finished
	$Token.position = end_p


func _hop_sample(start_p: Vector3, end_p: Vector3, u: float) -> void:
	var p: Vector3 = start_p.lerp(end_p, u)
	p.y = 0.55 + sin(u * PI) * 0.9
	$Token.position = p


func _tile_pos(i: int) -> Vector3:
	var ang: float = float(i) / 24.0 * TAU
	return Vector3(cos(ang) * RING, 0.55, sin(ang) * RING)


func _follow_cam(delta: float) -> void:
	_cam_boost = lerpf(_cam_boost, 0.0, 1.0 - exp(-delta * 0.9))
	if _walk_cam:
		var ang: float = atan2($Token.position.z, $Token.position.x)
		var tangent := Vector3(-sin(ang), 0, cos(ang))
		var outward := Vector3(cos(ang), 0, sin(ang))
		var cam: Vector3 = $Token.position - tangent * 2.4 + outward * 0.35 + Vector3(0, 1.62, 0)
		var look: Vector3 = $Token.position + tangent * 5.0 + Vector3(0, 1.25, 0)
		$CamWalk.fov = 55.0
		$CamWalk.global_position = $CamWalk.global_position.lerp(cam, 1.0 - exp(-delta * 4.0))
		if $CamWalk.global_position.distance_to(look) > 0.2:
			$CamWalk.look_at(look, Vector3.UP)
		$CamWalk.current = true
		$CamAerial.current = false
		return
	# Aerial ~35° matching the locked island painting — whole ring in frame.
	var cam2 := Vector3(20.0, 22.0 + _cam_boost, 24.0)
	var look2 := Vector3(0.0, 0.3, 0.0)
	$CamAerial.fov = 42.0
	$CamAerial.global_position = $CamAerial.global_position.lerp(cam2, 1.0 - exp(-delta * 2.2))
	if $CamAerial.global_position.distance_to(look2) > 0.3:
		$CamAerial.look_at(look2, Vector3.UP)
	$CamAerial.current = true
	$CamWalk.current = false


func _pulse_current() -> void:
	for i in _tile_nodes.size():
		var n: Node3D = _tile_nodes[i]
		var on: bool = i == $Board.token_tile
		n.scale = n.scale.lerp(Vector3.ONE * (1.08 if on else 1.0), 0.18)


func _build_player_token() -> void:
	for c in $Token.get_children():
		c.queue_free()
	if $Token is CSGPrimitive3D:
		($Token as CSGSphere3D).radius = 0.001
	IslandKit.add_adult_token($Token, Vector3(0, 0, 0), Color("#E07A5F"))


func _build() -> void:
	var sky := IslandKit.mat(Color(0.55, 0.82, 0.9))
	sky.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var dome := SphereMesh.new()
	dome.radius = 90.0
	dome.height = 180.0
	dome.flip_faces = true
	IslandKit.inst(self, dome, Vector3(0, 8, 0), sky)

	# Ocean outside the atoll
	IslandKit.cyl(self, 42.0, 42.0, 0.4, Vector3(0, -0.55, 0), Color("#0B6E6F"), 32)
	# Inner sand
	IslandKit.cyl(self, 7.3, 7.6, 0.45, Vector3(0, -0.05, 0), Color("#E8D5A8"), 24)
	# Lagoon pool
	var lagoon := IslandKit.cyl(self, 2.9, 2.9, 0.2, Vector3(0.4, 0.12, 0.6), Color("#2EC4B6"), 24)
	var wmat := ShaderMaterial.new()
	if ResourceLoader.exists("res://art/seasons/paloma/water.gdshader"):
		wmat.shader = load("res://art/seasons/paloma/water.gdshader")
		lagoon.material_override = wmat
	# Wooden boardwalk ring
	IslandKit.torus(self, 8.25, 10.55, Vector3(0, 0.06, 0), Color("#C4A35A"))
	_build_tiles()
	_build_village()
	var tm: Node3D = IslandKit.add_tide_machine(self, Vector3(3.4, 0.05, 1.6))
	tm.scale = Vector3(1.35, 1.35, 1.35)
	IslandKit.add_pelican(self, Vector3(7.6, 0.0, -7.4))
	_lights()


func _build_tiles() -> void:
	_tile_nodes.clear()
	for i in 24:
		var ang: float = float(i) / 24.0 * TAU
		var p := Vector3(cos(ang) * RING, 0.22, sin(ang) * RING)
		var root := Node3D.new()
		root.position = p
		root.rotation.y = -ang
		root.name = "Tile_%02d" % i
		add_child(root)
		_tile_nodes.append(root)
		var id: String = str($Board.tile_at(i).get("id", ""))
		var icon_name: String = str(TILE_ICON.get(id, "star"))
		var path := "res://art/seasons/paloma/tiles/%s.png" % icon_name
		var tex: Texture2D = load(path) if ResourceLoader.exists(path) else null
		var pad := BoxMesh.new()
		pad.size = Vector3(1.62, 0.2, 1.62)
		var pad_n := IslandKit.inst(root, pad, Vector3.ZERO, IslandKit.mat(Color.WHITE, 0.55, tex))
		pad_n.name = "Pad"
		var label: String = str($Board.tile_at(i).get("label", ""))
		if label != "":
			var post := IslandKit.cyl(root, 0.07, 0.08, 1.25, Vector3(0, 0.85, -0.55), Color("#C4A35A"), 8)
			var sign := Label3D.new()
			sign.text = label
			sign.font_size = 72
			sign.pixel_size = 0.012
			sign.position = Vector3(0, 1.7, -0.55)
			sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			sign.modulate = Color("#F7F1E3")
			sign.outline_modulate = Color("#1B1B1B")
			sign.outline_size = 10
			root.add_child(sign)
			var _p := post
			_p = _p


func _build_village() -> void:
	# Overwater bungalows — left arc of the painting
	for i in 5:
		var ang: float = deg_to_rad(155.0 + float(i) * 16.0)
		var p := Vector3(cos(ang) * 15.0, -0.15, sin(ang) * 15.0)
		IslandKit.add_bungalow(self, p, ang + PI)
		IslandKit.add_palm(self, p + Vector3(cos(ang) * 1.4, 0, sin(ang) * 1.4), 0.85)
	# Poker pavilion
	var poker_ang := deg_to_rad(125.0)
	IslandKit.add_pavilion(self, Vector3(cos(poker_ang) * 14.4, -0.1, sin(poker_ang) * 14.4), poker_ang + PI, Color("#1F6B4A"))
	# Slots pavilion on the inner north sand
	IslandKit.add_pavilion(self, Vector3(-0.2, 0.05, -5.3), 0.0, Color("#6B3F24"))
	IslandKit.add_tiki_cabinet(self, Vector3(-0.7, 0.35, -5.1), PI)
	IslandKit.add_tiki_cabinet(self, Vector3(0.5, 0.35, -5.1), PI)
	# Dock + boats
	var dock_ang := deg_to_rad(210.0)
	var dock_p := Vector3(cos(dock_ang) * 12.0, -0.05, sin(dock_ang) * 12.0)
	IslandKit.box(self, Vector3(3.4, 0.12, 1.1), dock_p, Color("#C4A35A"), Vector3(0, rad_to_deg(dock_ang), 0))
	IslandKit.add_boat(self, dock_p + Vector3(cos(dock_ang + 0.4) * 1.6, -0.1, sin(dock_ang + 0.4) * 1.6), dock_ang, Color("#F7F1E3"))
	IslandKit.add_boat(self, dock_p + Vector3(cos(dock_ang + 0.7) * 2.2, -0.1, sin(dock_ang + 0.7) * 2.2), dock_ang, Color("#E07A5F"))
	IslandKit.add_boat(self, dock_p + Vector3(cos(dock_ang + 1.0) * 1.4, 0.05, sin(dock_ang + 1.0) * 1.4), dock_ang, Color("#2EC4B6"))
	# Palms on the inner beach
	for i in 8:
		var a: float = deg_to_rad(20.0 + float(i) * 28.0)
		IslandKit.add_palm(self, Vector3(cos(a) * 5.4, 0.05, sin(a) * 5.4), 1.0)
	# Adult guests on the sand — not children
	var shirts := [Color("#E07A5F"), Color("#2EC4B6"), Color("#F4A261"), Color("#F7F1E3"), Color("#C4A35A")]
	for i in 5:
		var a: float = deg_to_rad(40.0 + float(i) * 50.0)
		IslandKit.add_adult_token(self, Vector3(cos(a) * 4.4, 0.12, sin(a) * 4.4), shirts[i])


func _lights() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, 50, 0)
	sun.light_color = Color(1.0, 0.86, 0.62)
	sun.light_energy = 1.4
	add_child(sun)
	var fill := OmniLight3D.new()
	fill.position = Vector3(0, 5.0, 0)
	fill.light_color = Color("#2EC4B6")
	fill.light_energy = 0.45
	fill.omni_range = 22.0
	add_child(fill)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.55, 0.82, 0.9)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(1.0, 0.84, 0.62)
	e.ambient_light_energy = 0.7
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.glow_enabled = true
	e.glow_intensity = 0.18
	env.environment = e
	add_child(env)
	$CamAerial.environment = e


func _play_bed() -> void:
	_surf = AudioStreamPlayer.new()
	if ResourceLoader.exists("res://audio/surf.wav"):
		_surf.stream = load("res://audio/surf.wav")
		_surf.volume_db = -8.0
		add_child(_surf)
		_surf.play()
	if ResourceLoader.exists("res://audio/steel.wav"):
		var steel := AudioStreamPlayer.new()
		steel.stream = load("res://audio/steel.wav")
		steel.volume_db = -16.0
		add_child(steel)
		steel.play()
