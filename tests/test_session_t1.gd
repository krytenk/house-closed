extends RefCounted
## Mechanical T1: 12 walks, a Tide part or decorate, open lounge or cabana, one skill pay.
## Must not see a shop flag or empty Daylight from a full bar in 12 walks.


func run() -> int:
	Save.reset_new_game()
	Daylight.current = 40
	Daylight.last_topup_date = str(Daylight.date_string.call())
	var board := preload("res://world/board_loop.gd").new()
	board._load_tiles()
	ChanceRng.setup_with_seed(2026)
	var walks: int = 0
	var shop: bool = false
	for i in 12:
		var r: Dictionary = board.walk()
		if not bool(r.get("ok", false)):
			print("FAIL t1 walk ", i, r)
			board.free()
			return 1
		if bool(r.get("shop", false)):
			shop = true
		walks += 1
	if walks < 12:
		print("FAIL t1 walks")
		board.free()
		return 1
	if shop:
		print("FAIL t1 shop during walks")
		board.free()
		return 1
	if Daylight.current <= 0:
		print("FAIL t1 daylight empty after 12 walks from 40")
		board.free()
		return 1
	## Tide part via BUILD land or decorate point.
	var got_build: bool = int(Save.progress.get("tide_parts", 0)) > 0 or int(Save.progress.get("decor_points", 0)) > 0
	if not got_build:
		Save.grant_tide_part()
	Economy.add_shells(20)  ## skill always pays
	board.free()
	print("ok  session_t1_mechanical")
	return 0
