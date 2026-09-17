extends CanvasLayer


func _ready() -> void:
	$Root/Walk.text = Game.text("walk")
	$Root/House.text = Game.text("house")
	$Root/PauseBtn.text = Game.text("pause")
	$Root/Walk.custom_minimum_size = Vector2(160, 56)
	$Root/House.custom_minimum_size = Vector2(160, 56)
	$Root/PauseBtn.custom_minimum_size = Vector2(160, 56)
	$Root/Walk.pressed.connect(_on_walk)
	$Root/House.pressed.connect(_on_house)
	$Root/PauseBtn.pressed.connect(_on_pause)
	$Root/ZeroBox/ReturnHouse.text = Game.text("return_to_house")
	$Root/ZeroBox/ReturnHouse.custom_minimum_size = Vector2(280, 56)
	$Root/ZeroBox/ReturnHouse.pressed.connect(_on_house)
	$Root/ZeroBox.visible = false
	$Root/Toast.visible = false
	$Root/Shades.gui_input.connect(_on_shades_input)


func _process(_delta: float) -> void:
	Daylight.apply_clock()
	$Root/Daylight.text = "%d/40" % Daylight.current
	$Root/Shells.text = str(Economy.hud_amount())
	$Root/Walk.disabled = Daylight.current <= 0
	$Root/ZeroBox.visible = Daylight.current <= 0
	if $Root/ZeroBox.visible:
		$Root/ZeroBox/Msg.text = Game.text("daylight_returns")


func _on_walk() -> void:
	Game.request_walk()


func _on_house() -> void:
	Game.goto("lobby")


func _on_pause() -> void:
	Game.goto("pause")


func _on_shades_input(_event: InputEvent) -> void:
	## Portrait opens nothing.
	pass


func show_toast(msg: String) -> void:
	$Root/Toast.text = msg
	$Root/Toast.visible = true
	get_tree().create_timer(2.4).timeout.connect(func() -> void: $Root/Toast.visible = false)
