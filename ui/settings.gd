extends Control


func _ready() -> void:
	$Title.text = Game.text("settings")
	$FunOnly.text = Game.text("fun_only")
	$PlaySafe.pressed.connect(func() -> void: Game.goto("play_safe"))
	$PlaySafe.custom_minimum_size = Vector2(280, 56)
	$Back.custom_minimum_size = Vector2(280, 56)
	$Back.pressed.connect(_back)
	$RegionWA.pressed.connect(func() -> void:
		RegionPolicy.forced_region = "US-WA"
		Save.write_disk()
		$RegionLabel.text = "Region: US-WA"
	)
	$RegionClear.pressed.connect(func() -> void:
		RegionPolicy.forced_region = ""
		Save.write_disk()
		$RegionLabel.text = "Region: auto"
	)
	$RegionLabel.text = "Region: %s" % (RegionPolicy.region_code() if RegionPolicy.region_code() != "" else "auto")


func _back() -> void:
	if Game.current_scene_key == "settings":
		Game.goto("lobby")
