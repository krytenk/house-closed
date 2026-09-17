extends Control


func _ready() -> void:
	$Title.text = Game.text("play_safe")
	$FunOnly.text = Game.text("fun_only")
	$Session.text = "Session: %d min" % PlaySafe.session_minutes()
	$DailyCap.text = "Daily cap $%.2f" % PlaySafe.daily_cap
	$WeeklyCap.text = "Weekly cap $%.2f" % PlaySafe.weekly_cap
	$DailySlider.min_value = 0
	$DailySlider.max_value = 15
	$DailySlider.step = 1
	$DailySlider.value = PlaySafe.daily_cap
	$DailySlider.value_changed.connect(_on_daily)
	$Cool24.pressed.connect(func() -> void: PlaySafe.start_cool_off(24 * 3600); _refresh())
	$Cool7.pressed.connect(func() -> void: PlaySafe.start_cool_off(7 * 86400); _refresh())
	$Cool30.pressed.connect(func() -> void: PlaySafe.start_cool_off(30 * 86400); _refresh())
	$Ex180.pressed.connect(func() -> void: PlaySafe.start_self_exclude(180 * 86400, false); _refresh())
	$ExPerm.pressed.connect(func() -> void: PlaySafe.start_self_exclude(-1, false); _refresh())
	$FullLock.pressed.connect(func() -> void: PlaySafe.start_self_exclude(-1, true); _refresh())
	$Delete.pressed.connect(_on_delete)
	$Back.pressed.connect(func() -> void: Game.goto("lobby"))
	for b in [$Cool24, $Cool7, $Cool30, $Ex180, $ExPerm, $FullLock, $Delete, $Back]:
		b.custom_minimum_size = Vector2(280, 52)
	_refresh()
	Game.log_event("play_safe", {"open": true})


func _on_daily(v: float) -> void:
	PlaySafe.set_daily_cap(v)
	_refresh()


func _on_delete() -> void:
	PlaySafe.request_delete()
	Save.delete_local()
	Game.goto("splash")


func _refresh() -> void:
	$Status.text = ""
	if PlaySafe.is_cool_off():
		$Status.text = Game.text("cool_off_on")
	if PlaySafe.is_self_excluded():
		$Status.text = Game.text("self_exclude_on")
	if PlaySafe.full_lock:
		$Status.text = Game.text("taking_a_break")
	$DailyCap.text = "Daily cap $%.2f" % PlaySafe.daily_cap
	Save.write_disk()
	Game.log_event("play_safe", {"cool_off": PlaySafe.is_cool_off(), "self_exclude": PlaySafe.is_self_excluded()})
