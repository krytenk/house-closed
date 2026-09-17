extends RefCounted


func run() -> int:
	PlaySafe.reset_new_game()
	RegionPolicy.forced_region = ""
	AiRng.setup_with_seed(7)
	var hole := ["As", "Ks"]
	var board := ["2c", "7d", "9h"]
	var a: String = PokerAI.decide("Lagoon", hole, board, 50, 150, 1000, true)
	AiRng.setup_with_seed(7)
	IapStub.mock_purchase("felt_sunset_alt", true)
	var b: String = PokerAI.decide("Lagoon", hole, board, 50, 150, 1000, true)
	if a != b:
		print("FAIL purchase changed poker ai ", a, " ", b)
		return 1
	print("ok  purchase_does_not_change_poker_ai")
	return 0
