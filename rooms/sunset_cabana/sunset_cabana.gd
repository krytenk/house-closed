extends Control

var mode: String = ""  ## human | practice
var credits_moved: bool = false
var waiting: bool = false
var coach: bool = false
var last_hand: Dictionary = {}


func _ready() -> void:
	$Plate.text = Game.text("door_poker_plate")
	$FunOnly.text = Game.text("fun_only")
	$Felt.text = Game.text("felt_plaque")
	$Kenji.text = "Kenji"
	$Human.text = Game.text("human_label")
	$Practice.text = Game.text("practice_ai_label")
	$Back.custom_minimum_size = Vector2(240, 56)
	$Human.custom_minimum_size = Vector2(280, 56)
	$Practice.custom_minimum_size = Vector2(280, 56)
	$Deal.custom_minimum_size = Vector2(240, 56)
	$Human.pressed.connect(_pick_human)
	$Practice.pressed.connect(_pick_practice)
	$Deal.pressed.connect(_deal)
	$Back.pressed.connect(_back)
	$Deal.visible = false
	$Table.visible = false
	$Coach.button_pressed = false
	$Coach.toggled.connect(func(v: bool) -> void: coach = v)
	$Coach.visible = false


func _pick_human() -> void:
	if not OS.get_name() in ["Android", "Windows", "Linux", "Web"] :
		pass
	## Offline: door disabled copy.
	if not _has_connection():
		Game.toast(Game.text("need_connection_human"))
		$Status.text = Game.text("need_connection_human")
		return
	if not PlaySafe.lounge_salon_human_allowed():
		Game.toast(Game.text("self_exclude_on"))
		return
	mode = "human"
	waiting = true
	$Status.text = "Looking for a table…"
	$Human.disabled = true
	$Practice.disabled = true
	get_tree().create_timer(20.0).timeout.connect(_human_timeout)


func _has_connection() -> bool:
	return IP.get_local_addresses().size() > 0


func _human_timeout() -> void:
	if not waiting or mode != "human":
		return
	waiting = false
	$Status.text = Game.text("play_now_labeled_ai")
	$Practice.disabled = false
	$Practice.text = Game.text("play_now_labeled_ai")


func _pick_practice() -> void:
	if not PlaySafe.practice_poker_allowed():
		Game.toast(Game.text("taking_a_break"))
		return
	mode = "practice"
	credits_moved = false  ## house credits, never convert
	Economy.practice_credits = 1000
	$Status.text = Game.text("ai_practice_nameplate")
	$Deal.visible = true
	$Table.visible = true
	$Coach.visible = true
	$Human.disabled = true
	$Practice.disabled = true


func _deal() -> void:
	if mode == "":
		return
	if not Game.can_spin_or_deal() and mode != "practice":
		Game.toast(Game.text("daylight_returns"))
		return
	if mode == "human" and not credits_moved:
		if not Economy.spend_shells(Holdem.SNG_BUYIN):
			$Status.text = "Need 500 Shells"
			return
		credits_moved = true
		Economy.enter_table_room()
	var st: Dictionary = Holdem.deal_table(6)
	var holes: Array = st["holes"]
	Holdem.burn_and_flop(st)
	Holdem.burn_and_one(st)
	Holdem.burn_and_one(st)
	var board: Array = st["board"]
	var styles := ["Reef", "Breaker", "Lagoon", "Reef", "Breaker"]
	var actions: Array = []
	for i in range(1, 6):
		var act: String = PokerAI.decide(styles[i - 1], holes[i], board, 0, 75, 1000, true)
		actions.append({"seat": i, "name": "AI — Practice" if mode == "practice" else styles[i - 1], "action": act, "style": styles[i - 1]})
	var alive: Array = [0]
	for a in actions:
		if str((a as Dictionary).get("action", "")) != "fold":
			alive.append(int((a as Dictionary).get("seat", 1)))
	var win: int = Holdem.winner_index(holes, board, alive)
	last_hand = {"holes": holes, "board": board, "winner": win, "actions": actions, "mode": mode}
	$Board.text = " ".join(PackedStringArray(board))
	$Hole.text = " ".join(PackedStringArray(holes[0]))
	$Winner.text = "Seat %d" % win
	if mode == "practice":
		$Nameplates.text = "AI — Practice · AI — Practice · AI — Practice · AI — Practice · AI — Practice"
	Save.progress["hold_em_hands"] = int(Save.progress.get("hold_em_hands", 0)) + 1
	Save.write_disk()


func _back() -> void:
	if Economy.in_table_room:
		Game.leave_chance_room()
	else:
		Game.goto("island")
