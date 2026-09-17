extends RefCounted


func run() -> int:
	PlaySafe.reset_new_game()
	RegionPolicy.forced_region = ""
	PalmReels.loaded = false
	PalmReels.load_table()
	ChanceRng.setup_with_seed(99)
	var a: Dictionary = PalmReels.play(1)
	ChanceRng.setup_with_seed(99)
	IapStub._load_catalog()
	IapStub.mock_purchase("cabinet_skin_orchid", true)
	var b: Dictionary = PalmReels.play(1)
	if JSON.stringify(a.get("first", {})) != JSON.stringify(b.get("first", {})):
		print("FAIL purchase changed palm reels")
		return 1
	if int(a.get("total", -1)) != int(b.get("total", -2)):
		print("FAIL purchase changed total")
		return 1
	print("ok  purchase_does_not_change_slots")
	return 0
