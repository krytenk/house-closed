extends Node

const SCENES := {
	"splash": "res://ui/boot/splash.tscn",
	"age_gate": "res://ui/boot/age_gate.tscn",
	"lock": "res://ui/boot/disclaimer_lock.tscn",
	"lobby": "res://world/hotel_lobby/lobby.tscn",
	"island": "res://world/paloma_atoll.tscn",
	"casino_floor": "res://rooms/tiki_lounge/casino_floor.tscn",
	"slot_palm": "res://rooms/tiki_lounge/slot_palm.tscn",
	"lounge": "res://rooms/tiki_lounge/casino_floor.tscn",
	"cabana": "res://rooms/sunset_cabana/sunset_cabana.tscn",
	"salon": "res://rooms/coral_salon/coral_salon.tscn",
	"tide": "res://world/tide_machine/tide_machine.tscn",
	"jetski": "res://minis/jetski_slalom/jetski_slalom.tscn",
	"coconut_shy": "res://minis/coconut_shy/coconut_shy.tscn",
	"recipe_mix": "res://minis/recipe_mix/recipe_mix.tscn",
	"bungalow": "res://world/bungalow/bungalow.tscn",
	"play_safe": "res://ui/play_safe.tscn",
	"settings": "res://ui/settings.tscn",
	"pause": "res://ui/pause.tscn",
	"shop": "res://world/hotel_lobby/desk_shop.tscn",
	"postcards": "res://ui/postcard_album.tscn",
	"nightclub": "res://world/hotel_lobby/nightclub.tscn",
	"break": "res://ui/boot/break_lobby.tscn",
	"odds": "res://ui/odds_sheet.tscn",
}

var last_event: Dictionary = {}
var hud: CanvasLayer
var last_die: int = 0
var last_toast: String = ""
var current_scene_key: String = "splash"
var pending_door: String = ""  ## second tap required


func _ready() -> void:
	_ensure_hud()
	Save.apply_clocks()


func _process(_delta: float) -> void:
	Save.apply_clocks()
	if PlaySafe.clock_notice_due() and current_scene_key != "splash":
		toast(Save.text("session_clock", {"minutes": PlaySafe.session_minutes()}))


func text(key: String, subs: Dictionary = {}) -> String:
	return Save.text(key, subs)


func log_event(kind: String, payload: Dictionary = {}) -> void:
	## Allowlist: session length, Play Safe changes, room enters, IAP SKU.
	var allowed := PackedStringArray(["session_length", "play_safe", "room_enter", "iap_sku"])
	if not allowed.has(kind):
		return
	last_event = {"kind": kind, "payload": payload}


func toast(msg: String) -> void:
	last_toast = msg
	if hud and hud.has_method("show_toast"):
		hud.call("show_toast", msg)


func goto(key: String) -> void:
	if PlaySafe.full_lock and key != "break" and key != "play_safe" and key != "settings":
		key = "break"
	if not SCENES.has(key):
		push_error("Unknown scene " + key)
		return
	if key in ["lounge", "salon", "cabana", "casino_floor", "slot_palm"] and not RegionPolicy.chance_rooms_open():
		toast(text("wa_chance_block"))
		return
	if key in ["lounge", "salon", "slot_palm"] and not PlaySafe.chance_staking_allowed():
		toast(text("cool_off_on"))
		return
	if key in ["lounge", "salon", "casino_floor", "slot_palm"] and not PlaySafe.lounge_salon_human_allowed():
		toast(text("self_exclude_on"))
		return
	current_scene_key = key
	if key in ["lounge", "salon", "cabana", "island", "lobby", "casino_floor", "slot_palm", "jetski", "coconut_shy", "recipe_mix"]:
		log_event("room_enter", {"room": key})
	_set_hud_visible(key in ["island"])
	get_tree().change_scene_to_file(SCENES[key])


func advance_boot() -> void:
	if not Save.age_verified:
		goto("age_gate")
		return
	if not Save.disclaimer_accepted:
		goto("lock")
		return
	if PlaySafe.full_lock:
		goto("break")
		return
	goto("lobby")


func accept_age() -> void:
	Save.age_verified = true
	Save.write_disk()
	advance_boot()


func accept_disclaimer() -> void:
	if not Save.age_verified:
		goto("age_gate")
		return
	Save.disclaimer_accepted = true
	Save.write_disk()
	goto("lobby")


func request_walk() -> Dictionary:
	Daylight.apply_clock()
	if Daylight.current <= 0:
		toast(text("daylight_returns"))
		return {"ok": false, "reason": "daylight", "shop": false}
	if not has_node("/root/BoardLoop") and get_tree().current_scene and get_tree().current_scene.has_method("walk"):
		return get_tree().current_scene.call("walk")
	var board := get_tree().get_first_node_in_group("board_loop")
	if board and board.has_method("walk"):
		return board.call("walk")
	## Fallback: roll and spend without a board node (tests).
	last_die = ChanceRng.die_d6()
	var steps: int = Daylight.try_spend_up_to(last_die)
	if steps <= 0:
		toast(text("daylight_returns"))
		return {"ok": false, "reason": "daylight", "shop": false, "die": last_die}
	return {"ok": true, "die": last_die, "steps": steps, "shop": false}


func can_start_mini() -> bool:
	Daylight.apply_clock()
	return Daylight.current > 0


func can_spin_or_deal() -> bool:
	Daylight.apply_clock()
	if Daylight.current <= 0:
		return false
	return true


func enter_chance_room(key: String) -> void:
	if not can_spin_or_deal() and key != "cabana":
		toast(text("daylight_returns"))
		return
	if key != "cabana":
		if not PlaySafe.chance_staking_allowed():
			toast(text("cool_off_on"))
			return
	if key == "slot_palm":
		Economy.enter_table_room()
	elif key != "cabana" and key != "casino_floor":
		Economy.enter_table_room()
	goto(key)


func leave_chance_room() -> void:
	if current_scene_key in ["lounge", "salon", "slot_palm"]:
		var net: int = Economy.reality_check_net()
		toast(text("reality_check", {"spins": Economy.spins_today, "net": net}))
	Economy.exit_table_room()
	Save.write_disk()
	goto("casino_floor")


func _ensure_hud() -> void:
	if hud != null:
		return
	var packed := load("res://ui/hud.tscn")
	if packed == null:
		return
	hud = packed.instantiate()
	hud.visible = false
	add_child(hud)


func play_sfx(kind: String) -> void:
	var path := ""
	match kind:
		"click":
			path = "res://audio/click.wav"
		"win":
			path = "res://audio/win.wav"
		_:
			return
	if not ResourceLoader.exists(path):
		return
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.finished.connect(p.queue_free)
	add_child(p)
	p.play()


func _set_hud_visible(v: bool) -> void:
	if hud:
		hud.visible = v
