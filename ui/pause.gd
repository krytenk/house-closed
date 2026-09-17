extends Control


func _ready() -> void:
	$Title.text = Game.text("pause")
	$Resume.text = "Resume"
	$PlaySafe.text = Game.text("play_safe")
	$Settings.text = Game.text("settings")
	$House.text = Game.text("house")
	for b in [$Resume, $PlaySafe, $Settings, $House]:
		b.custom_minimum_size = Vector2(280, 56)
	$Resume.pressed.connect(func() -> void: Game.goto("island"))
	$PlaySafe.pressed.connect(func() -> void: Game.goto("play_safe"))
	$Settings.pressed.connect(func() -> void: Game.goto("settings"))
	$House.pressed.connect(func() -> void: Game.goto("lobby"))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu") or event.is_action_pressed("ui_cancel"):
		Game.goto("island")
