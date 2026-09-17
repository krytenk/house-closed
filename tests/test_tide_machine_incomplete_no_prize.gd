extends RefCounted


func run() -> int:
	Save.progress["tide_parts"] = 3
	var before: int = Economy.hud_amount()
	var r: Dictionary = TideRules.crank()
	if bool(r.get("ok", true)):
		print("FAIL incomplete crank ok")
		return 1
	if int(r.get("prize", 1)) != 0:
		print("FAIL incomplete prize")
		return 1
	if bool(r.get("shop", true)):
		print("FAIL incomplete opened shop")
		return 1
	if Economy.hud_amount() != before:
		print("FAIL incomplete paid shells")
		return 1
	print("ok  tide_incomplete_no_prize")
	return 0
