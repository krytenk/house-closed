extends RefCounted


func run() -> int:
	Economy.reset_new_game()
	Daylight.reset_new_game()
	if Economy.shells != 1000:
		print("FAIL start shells")
		return 1
	if Daylight.current != 40:
		print("FAIL start daylight")
		return 1
	var board := preload("res://world/board_loop.gd").new()
	board._load_tiles()
	if board.tiles.size() != 24:
		print("FAIL tile count ", board.tiles.size())
		return 1
	if str(board.tile_at(11).get("label", "")) != "SLOTS":
		print("FAIL slots label")
		return 1
	if str(board.tile_at(7).get("label", "")) != "POKER":
		print("FAIL poker label")
		return 1
	if str(board.tile_at(15).get("label", "")) != "ROULETTE":
		print("FAIL roulette label")
		return 1
	Daylight.current = 40
	ChanceRng.setup_with_seed(1)
	var r: Dictionary = board.walk()
	if not bool(r.get("ok", false)):
		print("FAIL walk")
		return 1
	if bool(r.get("shop", false)):
		print("FAIL walk opened shop")
		return 1
	if int(r.get("steps", 0)) < 1:
		print("FAIL no steps")
		return 1
	board.free()
	print("ok  board_and_economy")
	return 0
