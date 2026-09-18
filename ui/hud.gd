extends CanvasLayer

var _die_t: float = 0.0
var _enter_label: String = ""


func _ready() -> void:
	$Root/Walk.pressed.connect(_on_walk)
	$Root/House.pressed.connect(_on_house)
	$Root/PauseBtn.pressed.connect(_on_pause)
	$Root/Enter.pressed.connect(_on_enter)
	$Root/ZeroBox/ReturnHouse.pressed.connect(_on_house)
	$Root/ZeroBox.visible = false
	$Root/Toast.visible = false
	$Root/Die.visible = false
	$Root/Enter.visible = false
	$Root/Walk.texture_normal = load("res://art/seasons/paloma/btn_walk.png")
	$Root/House.texture_normal = load("res://art/seasons/paloma/btn_house.png")
	$Root/PauseBtn.texture_normal = load("res://art/seasons/paloma/btn_pause.png")
	var pill := StyleBoxFlat.new()
	pill.bg_color = Color("#F7F1E3")
	pill.corner_radius_top_left = 22
	pill.corner_radius_top_right = 22
	pill.corner_radius_bottom_left = 22
	pill.corner_radius_bottom_right = 22
	pill.content_margin_left = 14
	pill.content_margin_right = 16
	pill.content_margin_top = 8
	pill.content_margin_bottom = 8
	$Root/TopBar/DayPill.add_theme_stylebox_override("panel", pill)
	$Root/TopBar/ShellPill.add_theme_stylebox_override("panel", pill.duplicate())


func _process(delta: float) -> void:
	Daylight.apply_clock()
	%DaylightNum.text = "%d" % Daylight.current
	%ShellsNum.text = str(Economy.hud_amount())
	$Root/Walk.modulate = Color(1, 1, 1, 0.45) if Daylight.current <= 0 else Color.WHITE
	$Root/ZeroBox.visible = Daylight.current <= 0 and Game.current_scene_key == "island"
	if $Root/ZeroBox.visible:
		$Root/ZeroBox/Msg.text = Game.text("daylight_returns")
	if $Root/Die.visible:
		_die_t -= delta
		if _die_t <= 0.0:
			$Root/Die.visible = false


func _on_walk() -> void:
	var island := _island()
	if island and island.has_method("try_walk"):
		island.call("try_walk")
		return
	Game.request_walk()


func _on_house() -> void:
	Game.goto("lobby")


func _on_pause() -> void:
	Game.goto("pause")


func _on_enter() -> void:
	var island := _island()
	if island and island.has_method("try_enter"):
		island.call("try_enter")


func _island() -> Node:
	return get_tree().get_first_node_in_group("paloma_island")


func set_enter(label: String) -> void:
	_enter_label = label
	$Root/Enter.visible = label != "" and Game.current_scene_key == "island"
	$Root/Enter.text = label


func show_die(n: int) -> void:
	$Root/Die.text = str(n)
	$Root/Die.visible = true
	$Root/Die.scale = Vector2(0.4, 0.4)
	_die_t = 0.85
	var tw := create_tween()
	tw.tween_property($Root/Die, "scale", Vector2(1.15, 1.15), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property($Root/Die, "scale", Vector2(1, 1), 0.08)


func show_toast(msg: String) -> void:
	$Root/Toast.text = msg
	$Root/Toast.visible = true
	get_tree().create_timer(2.2).timeout.connect(func() -> void: $Root/Toast.visible = false)
