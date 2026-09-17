extends RefCounted


func run() -> int:
	Save.progress["tide_parts"] = 6
	Save.progress["crank_day"] = ""
	var before: int = Economy.hud_amount()
	var r: Dictionary = TideRules.crank()
	if not bool(r.get("ok", false)):
		print("FAIL complete crank not ok")
		return 1
	if int(r.get("prize", 0)) != 40:
		print("FAIL prize ", r.get("prize", 0))
		return 1
	if Economy.hud_amount() != before + 40:
		print("FAIL shells not +40")
		return 1
	print("ok  tide_complete_pays_40")
	return 0
