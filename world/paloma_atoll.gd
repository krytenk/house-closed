extends Node3D
## The island IS the locked painting. Token walks that board. No hobby primitives.

const AERIAL := "res://art/seasons/paloma/refs/image-05e8804d-7548-4ffb-962a-96c8aa41acdd.jpg"
const WALKING := "res://art/seasons/paloma/refs/image-0f38715c-cde5-4938-86b8-eb2e5537ce66.jpg"
## Ellipse of the painted ring, in 0–1 image space (tuned to the aerial concept).
const CX := 0.500
const CY := 0.448
const RX := 0.395
const RY := 0.418
const ANG0 := 2.55  ## tile 0 (PORCH) near the bungalow arc

var _animating: bool = false
var _walk_cam: bool = false
var _surf: AudioStreamPlayer
var _shot_frames: int = 0
var _shot_path: String = ""
var _art: TextureRect
var _piece: TextureRect
var _layer: CanvasLayer


func _ready() -> void:
	add_to_group("paloma_island")
	$CamAerial.current = true
	$Token.visible = false
	_build_board()
	$Board.token_tile = int(Save.progress.get("token_tile", 0))
	_place_piece($Board.token_tile)
	Game._set_hud_visible(true)
	_play_bed()
	_shot_path = OS.get_environment("PALM_SHOT")
	set_process(true)


func _exit_tree() -> void:
	Game._set_hud_visible(false)
	if _surf:
		_surf.stop()


func _process(_delta: float) -> void:
	if _shot_path != "":
		_shot_frames += 1
		if _shot_frames == 16:
			var img: Image = get_viewport().get_texture().get_image()
			img.save_png(_shot_path)
			print("PALM_SHOT ", _shot_path, " ", img.get_width(), "x", img.get_height())
			get_tree().quit()
			return
	if not _animating and Input.is_action_just_pressed("walk"):
		try_walk()
	if Input.is_action_just_pressed("ui_cancel"):
		Game.goto("pause")
	if Input.is_action_just_pressed("ui_focus_next"):
		_walk_cam = not _walk_cam
		_art.texture = load(WALKING if _walk_cam else AERIAL)
		_place_piece($Board.token_tile)
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
	for k in steps:
		var idx: int = (start + k + 1) % 24
		await _hop_to(idx)
	_place_piece($Board.token_tile)
	_animating = false
	Game.play_sfx("click")
	return r


func try_enter() -> void:
	if _animating:
		return
	$Board.tap_current()


func _build_board() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 5
	add_child(_layer)
	_art = TextureRect.new()
	_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_art.texture = load(AERIAL)
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_art)
	_piece = TextureRect.new()
	_piece.texture = load("res://art/seasons/paloma/meeple.png")
	_piece.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_piece.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_piece.size = Vector2(56, 72)
	_piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_piece)


func _tile_uv(i: int) -> Vector2:
	var ang: float = ANG0 + float(i) / 24.0 * TAU
	return Vector2(CX + RX * cos(ang), CY + RY * sin(ang))


func _uv_to_screen(uv: Vector2) -> Vector2:
	var vr: Rect2 = get_viewport().get_visible_rect()
	## COVER: image fills the shorter side and may crop. Match TextureRect COVER.
	var tex: Texture2D = _art.texture
	if tex == null:
		return vr.size * uv
	var ts: Vector2 = tex.get_size()
	var scale: float = maxf(vr.size.x / ts.x, vr.size.y / ts.y)
	var drawn: Vector2 = ts * scale
	var origin: Vector2 = (vr.size - drawn) * 0.5
	return origin + Vector2(uv.x * drawn.x, uv.y * drawn.y)


func _place_piece(i: int) -> void:
	var p: Vector2 = _uv_to_screen(_tile_uv(i))
	_piece.position = p - _piece.size * 0.5


func _hop_to(idx: int) -> void:
	var start_p: Vector2 = _piece.position
	var end_p: Vector2 = _uv_to_screen(_tile_uv(idx)) - _piece.size * 0.5
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_method(_hop_sample.bind(start_p, end_p), 0.0, 1.0, 0.22)
	await tw.finished
	_place_piece(idx)


func _hop_sample(start_p: Vector2, end_p: Vector2, u: float) -> void:
	var p: Vector2 = start_p.lerp(end_p, u)
	p.y -= sin(u * PI) * 28.0
	_piece.position = p


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
