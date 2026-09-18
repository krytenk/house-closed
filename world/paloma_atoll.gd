extends Node3D
## Paloma Atoll — the toy diorama you actually play.

const RING := 9.4
const SHORT := {
	"PORCH": "PORCH",
	"BUNGALOW": "HOME",
	"PALM_PATH": "PALM",
	"BUILD_A": "TIDE",
	"MARINA_DOOR": "MARINA",
	"GUEST_BENCH": "GUEST",
	"BEACH": "BEACH",
	"POKER_DOOR": "POKER",
	"BUILD_B": "TIDE",
	"WILDLIFE": "SHADES",
	"LANTERN_PATH": "LANTERN",
	"SLOTS_DOOR": "SLOTS",
	"CRANK": "CRANK",
	"SPLASH": "SPLASH",
	"BUILD_C": "TIDE",
	"ROULETTE_DOOR": "ROULETTE",
	"COCONUT_GROVE": "GROVE",
	"FRIEND_DOCK": "DOCK",
	"BUILD_D": "TIDE",
	"LOOKOUT": "LOOKOUT",
	"NIGHTCLUB_DOOR": "LANTERN",
	"BUILD_E": "TIDE",
	"SPA_PATH": "SPA",
	"BUILD_F": "TIDE",
}

var _animating: bool = false
var _tile_nodes: Array = []
var _cam_boost: float = 22.0
var _surf: AudioStreamPlayer
var _shot_frames: int = 0
var _shot_path: String = ""


func _ready() -> void:
	add_to_group("paloma_island")
	RenderingServer.set_default_clear_color(Color(0.62, 0.84, 0.86))
	_build()
	$Board.token_tile = int(Save.progress.get("token_tile", 0))
	$Token.position = _tile_pos($Board.token_tile)
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
		if _shot_frames == 18:
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
	p.y = 0.62 + sin(u * PI) * 0.85
	$Token.position = p


func _tile_pos(i: int) -> Vector3:
	var ang: float = float(i) / 24.0 * TAU
	return Vector3(cos(ang) * RING, 0.62, sin(ang) * RING)


func _follow_cam(delta: float) -> void:
	var ang: float = atan2($Token.position.z, $Token.position.x)
	_cam_boost = lerpf(_cam_boost, 0.0, 1.0 - exp(-delta * 0.85))
	var dist: float = 19.0
	var height: float = 14.5 + _cam_boost
	var cam := Vector3(cos(ang) * dist, height, sin(ang) * dist)
	$CamAerial.fov = 46.0
	$CamAerial.global_position = $CamAerial.global_position.lerp(cam, 1.0 - exp(-delta * 2.4))
	var look := Vector3($Token.position.x * 0.18, 0.25, $Token.position.z * 0.18)
	if $CamAerial.global_position.distance_to(look) > 0.4:
		$CamAerial.look_at(look, Vector3.UP)
	$CamAerial.current = true


func _pulse_current() -> void:
	for i in _tile_nodes.size():
		var n: Node3D = _tile_nodes[i]
		var on: bool = i == $Board.token_tile
		n.scale = n.scale.lerp(Vector3.ONE * (1.12 if on else 1.0), 0.15)


func _build() -> void:
	var dome := MeshInstance3D.new()
	var dome_mesh := SphereMesh.new()
	dome_mesh.radius = 70.0
	dome_mesh.height = 140.0
	dome_mesh.flip_faces = true
	dome.mesh = dome_mesh
	var dome_mat := StandardMaterial3D.new()
	dome_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dome_mat.albedo_color = Color(0.55, 0.80, 0.84)
	dome.material_override = dome_mat
	add_child(dome)
	var wood_tex: Texture2D = load("res://art/seasons/paloma/wood.png")
	var water_tex: Texture2D = load("res://art/seasons/paloma/water.png")
	var sand := MeshInstance3D.new()
	var sand_m := CylinderMesh.new()
	sand_m.top_radius = 11.4
	sand_m.bottom_radius = 11.8
	sand_m.height = 0.28
	sand.mesh = sand_m
	sand.position = Vector3(0, -0.22, 0)
	sand.material_override = _mat(Palette.SAND, wood_tex)
	add_child(sand)
	var water := MeshInstance3D.new()
	var water_m := CylinderMesh.new()
	water_m.top_radius = 8.2
	water_m.bottom_radius = 8.2
	water_m.height = 0.18
	water.mesh = water_m
	water.position = Vector3(0, -0.02, 0)
	var sh := ShaderMaterial.new()
	sh.shader = load("res://art/seasons/paloma/water.gdshader")
	water.material_override = sh
	add_child(water)
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 8.55
	torus.outer_radius = 10.35
	torus.rings = 64
	torus.ring_segments = 16
	ring.mesh = torus
	ring.position = Vector3(0, 0.02, 0)
	ring.material_override = _mat(Palette.BAMBOO, wood_tex)
	add_child(ring)
	_tile_nodes.clear()
	for i in 24:
		var p: Vector3 = _tile_pos(i)
		p.y = 0.18
		var box := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(1.7, 0.22, 1.7)
		box.mesh = bm
		box.position = p
		box.rotation.y = -float(i) / 24.0 * TAU
		var id: String = str($Board.tile_at(i).get("id", ""))
		var col: Color = _tile_color(id)
		box.material_override = _mat(col, wood_tex)
		box.name = "Tile_%02d" % i
		add_child(box)
		_tile_nodes.append(box)
		var lab := Label3D.new()
		lab.text = str(SHORT.get(id, id))
		lab.font_size = 42
		lab.pixel_size = 0.01
		lab.position = p + Vector3(0, 0.52, 0)
		lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		lab.modulate = Palette.INK if col.v > 0.45 else Palette.CREAM
		lab.outline_modulate = Palette.CREAM
		lab.outline_size = 6
		add_child(lab)
		if str($Board.tile_at(i).get("label", "")) != "":
			var post := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = 0.06
			cm.bottom_radius = 0.08
			cm.height = 1.35
			post.mesh = cm
			post.position = p + Vector3(0, 0.85, 0)
			post.material_override = _mat(Palette.BAMBOO, wood_tex)
			add_child(post)
			var sign := Label3D.new()
			sign.text = str($Board.tile_at(i).get("label", ""))
			sign.font_size = 64
			sign.pixel_size = 0.014
			sign.position = p + Vector3(0, 1.65, 0)
			sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			sign.modulate = Palette.CREAM
			sign.outline_modulate = Palette.INK
			sign.outline_size = 8
			add_child(sign)
	_build_tide(wood_tex)
	_build_huts(wood_tex)
	_build_palms()
	_build_shades()
	_build_guests()
	var tok_mat := StandardMaterial3D.new()
	tok_mat.albedo_color = Palette.CORAL
	tok_mat.roughness = 0.35
	$Token.material = tok_mat
	$Token.radius = 0.48
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, 36, 0)
	sun.light_color = Color(1.0, 0.86, 0.62)
	sun.light_energy = 1.35
	sun.shadow_enabled = false
	add_child(sun)
	var fill := OmniLight3D.new()
	fill.position = Vector3(0, 4.5, 0)
	fill.light_color = Palette.LAGOON
	fill.light_energy = 0.55
	fill.omni_range = 18.0
	add_child(fill)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.55, 0.78, 0.82)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(1.0, 0.84, 0.62)
	e.ambient_light_energy = 0.62
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.glow_enabled = true
	e.glow_intensity = 0.22
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.12
	env.environment = e
	add_child(env)
	$CamAerial.environment = e
	var _w := water_tex
	_w = _w


func _build_tide(wood_tex: Texture2D) -> void:
	var base := MeshInstance3D.new()
	var bm := CylinderMesh.new()
	bm.top_radius = 1.15
	bm.bottom_radius = 1.35
	bm.height = 0.35
	base.mesh = bm
	base.position = Vector3(0, 0.2, 0)
	base.material_override = _mat(Palette.BAMBOO, wood_tex)
	add_child(base)
	for i in 6:
		var part := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.45, 0.35, 0.45)
		part.mesh = box
		var ang: float = float(i) / 6.0 * TAU
		var y: float = 0.55 + float(i) * 0.28
		part.position = Vector3(cos(ang) * 0.55, y, sin(ang) * 0.55)
		var on: bool = i < int(Save.progress.get("tide_parts", 0))
		part.material_override = _mat(Palette.CORAL if on else Palette.CREAM, wood_tex)
		add_child(part)
	var crank := MeshInstance3D.new()
	var arm := BoxMesh.new()
	arm.size = Vector3(1.4, 0.12, 0.12)
	crank.mesh = arm
	crank.position = Vector3(1.1, 1.1, 0)
	crank.material_override = _mat(Palette.INK)
	add_child(crank)
	var title := Label3D.new()
	title.text = "TIDE MACHINE"
	title.font_size = 48
	title.position = Vector3(0, 2.6, 0)
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.modulate = Palette.CREAM
	title.outline_modulate = Palette.INK
	title.outline_size = 8
	add_child(title)


func _build_huts(wood_tex: Texture2D) -> void:
	for i in 5:
		var ang: float = 0.45 + float(i) * 0.72
		var p := Vector3(cos(ang) * 4.4, 0.0, sin(ang) * 4.4)
		var hut := MeshInstance3D.new()
		var body := BoxMesh.new()
		body.size = Vector3(1.15, 0.95, 1.15)
		hut.mesh = body
		hut.position = p + Vector3(0, 0.55, 0)
		hut.material_override = _mat(Palette.CREAM, wood_tex)
		add_child(hut)
		var roof := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius = 0.02
		cone.bottom_radius = 0.95
		cone.height = 0.7
		roof.mesh = cone
		roof.position = p + Vector3(0, 1.25, 0)
		roof.material_override = _mat(Palette.BAMBOO, wood_tex)
		add_child(roof)


func _build_palms() -> void:
	for i in 7:
		var ang: float = 0.2 + float(i) * 0.85
		var p := Vector3(cos(ang) * 6.2, 0, sin(ang) * 6.2)
		var trunk := MeshInstance3D.new()
		var tm := CylinderMesh.new()
		tm.top_radius = 0.07
		tm.bottom_radius = 0.12
		tm.height = 2.1
		trunk.mesh = tm
		trunk.position = p + Vector3(0, 1.05, 0)
		trunk.material_override = _mat(Color("#6B4F2A"))
		add_child(trunk)
		var frond := MeshInstance3D.new()
		var fm := SphereMesh.new()
		fm.radius = 0.55
		fm.height = 0.7
		frond.mesh = fm
		frond.position = p + Vector3(0, 2.2, 0)
		frond.material_override = _mat(Color("#2E8B57"))
		add_child(frond)


func _build_shades() -> void:
	var sp := Sprite3D.new()
	sp.texture = load("res://art/seasons/paloma/shades.png")
	sp.pixel_size = 0.0042
	sp.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sp.position = Vector3(3.4, 1.35, 2.2)
	sp.shaded = false
	add_child(sp)
	var piling := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.18
	cm.bottom_radius = 0.22
	cm.height = 1.1
	piling.mesh = cm
	piling.position = Vector3(3.4, 0.4, 2.2)
	piling.material_override = _mat(Palette.BAMBOO)
	add_child(piling)


func _build_guests() -> void:
	var spots := [5, 10, 16, 22]
	for s in spots:
		var cap := MeshInstance3D.new()
		var m := CapsuleMesh.new()
		m.radius = 0.14
		m.height = 0.7
		cap.mesh = m
		var p: Vector3 = _tile_pos(s)
		p.y = 0.85
		p += Vector3(0.55, 0, 0.15)
		cap.position = p
		cap.material_override = _mat(Palette.CREAM)
		add_child(cap)


func _tile_color(id: String) -> Color:
	if id.ends_with("_DOOR") and id.find("NIGHT") == -1:
		return Palette.INK
	if id.begins_with("BUILD") or id == "CRANK":
		return Palette.BAMBOO
	if id == "SPLASH" or id == "BEACH" or id == "PALM_PATH":
		return Palette.LAGOON
	if id == "WILDLIFE":
		return Palette.AMBER
	if id == "PORCH":
		return Palette.SAND
	return Palette.SAND


func _mat(color: Color, tex: Texture2D = null) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.55
	if tex:
		m.albedo_texture = tex
		m.uv1_scale = Vector3(2, 2, 2)
	return m


func _play_bed() -> void:
	_surf = AudioStreamPlayer.new()
	if ResourceLoader.exists("res://audio/surf.wav"):
		_surf.stream = load("res://audio/surf.wav")
		_surf.volume_db = -8.0
		add_child(_surf)
		_surf.play()
	var steel := AudioStreamPlayer.new()
	if ResourceLoader.exists("res://audio/steel.wav"):
		steel.stream = load("res://audio/steel.wav")
		steel.volume_db = -16.0
		add_child(steel)
		steel.play()



