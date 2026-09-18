extends Control


func _ready() -> void:
	$MaraBubble/Line.text = Game.text("mara_welcome")
	$FunOnly.text = Game.text("fun_only")
	$Garden.pressed.connect(_garden)
	$Lounge.pressed.connect(func() -> void: Game.enter_chance_room("lounge"))
	$Cabana.pressed.connect(func() -> void: Game.goto("cabana"))
	$Salon.pressed.connect(func() -> void: Game.enter_chance_room("salon"))
	$Desk.pressed.connect(func() -> void: Game.goto("shop"))
	$Suite.pressed.connect(func() -> void: Game.goto("bungalow"))
	$PlaySafe.pressed.connect(func() -> void: Game.goto("play_safe"))
	$Kitchen.pressed.connect(func() -> void: Game.goto("recipe_mix"))
	$Nightclub.pressed.connect(func() -> void: Game.goto("nightclub"))
	_apply_locks()
	var shot: String = OS.get_environment("PALM_SHOT")
	if shot != "":
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(shot)
		print("PALM_SHOT ", shot)
		get_tree().quit()


func _garden() -> void:
	Save.first_run_complete = true
	Save.write_disk()
	Game.goto("island")


func _apply_locks() -> void:
	if not RegionPolicy.chance_rooms_open() or not PlaySafe.lounge_salon_human_allowed():
		$Lounge.disabled = true
		$Salon.disabled = true
		$Cabana.disabled = true
		$Blocked.text = Game.text("wa_chance_block") if not RegionPolicy.chance_rooms_open() else Game.text("self_exclude_on")
	if PlaySafe.full_lock:
		Game.goto("break")
