extends Node3D
## Sunset Cabana — felt table in a lantern pavilion. HUMAN vs PRACTICE before credits move.

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
	_build_room()
	_build_overlay()


func _build_room() -> void:
	RenderingServer.set_default_clear_color(Color(0.55, 0.32, 0.22))
	IslandKit.box(self, Vector3(14, 0.2, 12), Vector3(0, -0.1, 0), Color("#C4A35A"))
	# Open ocean
	IslandKit.box(self, Vector3(14, 5, 0.2), Vector3(0, 2.4, -6.1), Color("#C45C3A"))
	IslandKit.box(self, Vector3(14, 0.5, 5), Vector3(0, 0.1, -8), Color("#0B6E6F"))
	# Roof
	IslandKit.box(self, Vector3(14.4, 0.22, 12.4), Vector3(0, 4.2, 0), Color("#C9A15B"))
	for x in [-5.5, 5.5]:
		for z in [-4.2, 4.2]:
			IslandKit.cyl(self, 0.14, 0.16, 4.2, Vector3(x, 2.0, z), Color("#6B4F2A"), 8)
	# Felt table
	IslandKit.cyl(self, 2.1, 2.2, 0.18, Vector3(0, 0.95, 0), Color("#1F6B4A"), 24)
	IslandKit.cyl(self, 2.25, 2.3, 0.12, Vector3(0, 0.82, 0), Color("#6B3F24"), 24)
	IslandKit.cyl(self, 0.35, 0.4, 0.75, Vector3(0, 0.4, 0), Color("#6B3F24"), 10)
	# Chairs
	for i in 6:
		var a: float = float(i) / 6.0 * TAU
		IslandKit.box(self, Vector3(0.55, 0.7, 0.55), Vector3(cos(a) * 2.7, 0.45, sin(a) * 2.7), Color("#F7F1E3"))
	# Lanterns
	for i in 4:
		var a: float = float(i) / 4.0 * TAU + 0.4
		var p := Vector3(cos(a) * 2.0, 3.4, sin(a) * 2.0)
		IslandKit.cyl(self, 0.16, 0.2, 0.35, p, Color("#F4A261"), 8)
		var lamp := OmniLight3D.new()
		lamp.position = p
		lamp.light_color = Color("#F4A261")
		lamp.light_energy = 1.6
		lamp.omni_range = 6.0
		add_child(lamp)
	var cam := Camera3D.new()
	cam.fov = 40.0
	cam.position = Vector3(0, 2.4, 5.4)
	cam.current = true
	add_child(cam)
	cam.look_at(Vector3(0, 1.0, 0))
	var plate := Label3D.new()
	plate.text = "POKER"
	plate.font_size = 80
	plate.position = Vector3(0, 3.6, 0)
	plate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	plate.modulate = Color("#F7F1E3")
	plate.outline_modulate = Color("#1B1B1B")
	plate.outline_size = 8
	add_child(plate)
	var felt := Label3D.new()
	felt.text = Game.text("felt_plaque")
	felt.font_size = 28
	felt.position = Vector3(0, 1.15, 0.2)
	felt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	felt.modulate = Color("#F7F1E3")
	add_child(felt)


func _build_overlay() -> void:
	var overlay := CanvasLayer.new()
	add_child(overlay)
	_status = Label.new()
	_status.position = Vector2(80, 40)
	_status.size = Vector2(1760, 48)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.add_theme_font_size_override("font_size", 22)
	_status.add_theme_color_override("font_color", Color("#F7F1E3"))
	overlay.add_child(_status)
	_human = Button.new()
	_human.text = Game.text("human_label")
	_human.position = Vector2(640, 900)
	_human.size = Vector2(280, 56)
	_human.pressed.connect(_pick_human)
	overlay.add_child(_human)
	_practice = Button.new()
	_practice.text = Game.text("practice_ai_label")
	_practice.position = Vector2(1000, 900)
	_practice.size = Vector2(280, 56)
	_practice.pressed.connect(_pick_practice)
	overlay.add_child(_practice)
	_deal = Button.new()
	_deal.text = "Deal"
	_deal.visible = false
	_deal.position = Vector2(860, 980)
	_deal.size = Vector2(200, 52)
	_deal.pressed.connect(_deal_hand)
	overlay.add_child(_deal)
	var back := Button.new()
	back.text = Game.text("back")
	back.position = Vector2(24, 1000)
	back.size = Vector2(160, 52)
	back.pressed.connect(_back)
	overlay.add_child(back)
	_board = Label.new()
	_board.position = Vector2(80, 720)
	_board.size = Vector2(1760, 40)
	_board.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_board.add_theme_color_override("font_color", Color("#F7F1E3"))
	overlay.add_child(_board)
	_hole = Label.new()
	_hole.position = Vector2(80, 760)
	_hole.size = Vector2(1760, 40)
	_hole.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hole.add_theme_color_override("font_color", Color("#F7F1E3"))
	overlay.add_child(_hole)
	_winner = Label.new()
	_winner.position = Vector2(80, 800)
	_winner.size = Vector2(1760, 40)
	_winner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_winner.add_theme_color_override("font_color", Color("#F4A261"))
	overlay.add_child(_winner)


func _pick_human() -> void:
	if not _has_connection():
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


func _has_connection() -> bool:
	return IP.get_local_addresses().size() > 0


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
		actions.append({"seat": i, "action": act, "style": styles[i - 1]})
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
