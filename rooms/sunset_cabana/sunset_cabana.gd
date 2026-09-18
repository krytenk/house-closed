extends Control
## Sunset Cabana is the locked interior painting.

const ROOM := "res://art/seasons/paloma/refs/image-49189787-8373-4cba-91c2-87cd4c3866f5.jpg"

var mode: String = ""
var credits_moved: bool = false
var waiting: bool = false
var last_hand: Dictionary = {}
var _status: Label
var _deal: Button
var _human: Button
var _practice: Button
var _board: Label
var _hole: Label
var _winner: Label


func _ready() -> void:
	var photo := TextureRect.new()
	photo.set_anchors_preset(Control.PRESET_FULL_RECT)
	photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	photo.texture = load(ROOM)
	photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(photo)
	_status = _lbl(Vector2(40, 16), Vector2(1840, 40), Game.text("felt_plaque"), 20)
	_human = _btn(Vector2(640, 900), Vector2(280, 56), Game.text("human_label"), _pick_human)
	_practice = _btn(Vector2(1000, 900), Vector2(280, 56), Game.text("practice_ai_label"), _pick_practice)
	_deal = _btn(Vector2(860, 980), Vector2(200, 52), "Deal", _deal_hand)
	_deal.visible = false
	_btn(Vector2(24, 1000), Vector2(160, 52), Game.text("back"), _back)
	_board = _lbl(Vector2(40, 720), Vector2(1840, 36), "", 22)
	_hole = _lbl(Vector2(40, 760), Vector2(1840, 36), "", 22)
	_winner = _lbl(Vector2(40, 800), Vector2(1840, 36), "", 22)


func _lbl(pos: Vector2, sz: Vector2, text: String, size: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = sz
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("#F7F1E3"))
	l.add_theme_color_override("font_outline_color", Color("#1B1B1B"))
	l.add_theme_constant_override("outline_size", 6)
	add_child(l)
	return l


func _btn(pos: Vector2, sz: Vector2, text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.position = pos
	b.size = sz
	b.text = text
	b.pressed.connect(cb)
	add_child(b)
	return b


func _pick_human() -> void:
	if IP.get_local_addresses().is_empty():
		Game.toast(Game.text("need_connection_human"))
		_status.text = Game.text("need_connection_human")
		return
	if not PlaySafe.lounge_salon_human_allowed():
		Game.toast(Game.text("self_exclude_on"))
		return
	mode = "human"
	waiting = true
	_status.text = "Looking for a table…"
	_human.disabled = true
	_practice.disabled = true
	get_tree().create_timer(20.0).timeout.connect(_human_timeout)


func _human_timeout() -> void:
	if not waiting or mode != "human":
		return
	waiting = false
	_status.text = Game.text("play_now_labeled_ai")
	_practice.disabled = false
	_practice.text = Game.text("play_now_labeled_ai")


func _pick_practice() -> void:
	if not PlaySafe.practice_poker_allowed():
		Game.toast(Game.text("taking_a_break"))
		return
	mode = "practice"
	credits_moved = false
	Economy.practice_credits = 1000
	_status.text = Game.text("ai_practice_nameplate")
	_deal.visible = true
	_human.disabled = true
	_practice.disabled = true


func _deal_hand() -> void:
	if mode == "":
		return
	if not Game.can_spin_or_deal() and mode != "practice":
		Game.toast(Game.text("daylight_returns"))
		return
	if mode == "human" and not credits_moved:
		if not Economy.spend_shells(Holdem.SNG_BUYIN):
			_status.text = "Need 500 Shells"
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
		actions.append({"seat": i, "action": act})
	var alive: Array = [0]
	for a in actions:
		if str((a as Dictionary).get("action", "")) != "fold":
			alive.append(int((a as Dictionary).get("seat", 1)))
	var win: int = Holdem.winner_index(holes, board, alive)
	last_hand = {"holes": holes, "board": board, "winner": win, "mode": mode}
	_board.text = " ".join(PackedStringArray(board))
	_hole.text = " ".join(PackedStringArray(holes[0]))
	_winner.text = "Seat %d" % win
	Save.progress["hold_em_hands"] = int(Save.progress.get("hold_em_hands", 0)) + 1
	Save.write_disk()


func _back() -> void:
	if Economy.in_table_room:
		Game.leave_chance_room()
	else:
		Game.goto("island")
