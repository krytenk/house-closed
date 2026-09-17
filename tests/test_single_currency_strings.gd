extends RefCounted


func run() -> int:
	var blob: String = JSON.stringify(Save.copy) + JSON.stringify(IapStub.catalog)
	for bad in ["Sweeps", "sweeps", "Gold Coins", "Beads", "cash out", "WIN BIG", "LAST CHANCE"]:
		if blob.find(bad) != -1:
			print("FAIL forbidden string ", bad)
			return 1
	if Save.text("fun_only").find("FOR FUN ONLY") == -1:
		print("FAIL fun_only copy")
		return 1
	print("ok  single_currency_strings")
	return 0
