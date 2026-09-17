extends Control


func _ready() -> void:
	$Chalk.text = "Paloma House"
	$Mara.text = Game.text("mara_welcome")
	$FunOnly.text = Game.text("fun_only")
	$NoticeDaylight.text = "Daylight %d/40" % Daylight.current
	$NoticeShells.text = "Shells %d" % Economy.hud_amount()
	$PlaySafe.custom_minimum_size = Vector2(240, 56)
	$PlaySafe.pressed.connect(func() -> void: Game.goto("play_safe"))
	$Lounge.pressed.connect(func() -> void: Game.enter_chance_room("lounge"))
	$Cabana.pressed.connect(func() -> void: Game.goto("cabana"))
	$Salon.pressed.connect(func() -> void: Game.enter_chance_room("salon"))
	$Garden.pressed.connect(func() -> void: Game.goto("island"))
	$Suite.pressed.connect(func() -> void: Game.goto("bungalow"))
	$Desk.pressed.connect(func() -> void: Game.goto("shop"))
	$Nightclub.pressed.connect(func() -> void: Game.goto("nightclub"))
	$Kitchen.pressed.connect(func() -> void: Game.goto("recipe_mix"))
	$Postcards.pressed.connect(func() -> void: Game.goto("postcards"))
	$Arthur.text = "Arthur"
	$Nia.text = "Nia"
	for b in [$Lounge, $Cabana, $Salon, $Garden, $Suite, $Desk, $Nightclub, $Kitchen, $Postcards]:
		b.custom_minimum_size = Vector2(240, 52)
	_apply_locks()


func _apply_locks() -> void:
	if not RegionPolicy.chance_rooms_open():
		$Lounge.disabled = true
		$Salon.disabled = true
		$Cabana.disabled = true
		$Blocked.text = Game.text("wa_chance_block")
	if not PlaySafe.lounge_salon_human_allowed():
		$Lounge.disabled = true
		$Salon.disabled = true
		$Cabana.disabled = true
		$Blocked.text = Game.text("self_exclude_on")
	if PlaySafe.full_lock:
		Game.goto("break")
