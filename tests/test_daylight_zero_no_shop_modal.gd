extends RefCounted


func run() -> int:
	Daylight.current = 0
	Daylight.last_topup_date = str(Daylight.date_string.call())
	Daylight.last_regen_unix = int(Daylight.time_unix.call())
	var r: Dictionary = Game.request_walk()
	if bool(r.get("ok", true)):
		print("FAIL walk ok at 0 daylight")
		return 1
	if bool(r.get("shop", true)):
		print("FAIL shop prompt at 0 daylight")
		return 1
	if Game.last_toast.find("Daylight") == -1 and Game.last_toast.find("clock") == -1:
		print("FAIL toast ", Game.last_toast)
		return 1
	print("ok  daylight_zero_no_shop")
	return 0
