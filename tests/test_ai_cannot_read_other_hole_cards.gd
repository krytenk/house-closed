extends RefCounted


func run() -> int:
	var src: String = FileAccess.get_file_as_string("res://rooms/sunset_cabana/poker_ai.gd")
	if src.find("other_hole") != -1 or src.find("other_holes") != -1 or src.find("god_mode") != -1:
		print("FAIL ai source mentions other hole cards")
		return 1
	## API has no slot for enemy cards.
	var m: String = PokerAI.decide("Reef", ["2c", "3d"], ["Ah", "Kd", "Qc"], 0, 75, 1000, true)
	if m == "":
		print("FAIL decide return")
		return 1
	print("ok  ai_cannot_read_other_hole_cards")
	return 0
