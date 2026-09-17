extends RefCounted


func run() -> int:
	IapStub._load_catalog()
	if IapStub.any_sku_named_forbidden():
		print("FAIL daylight/energy/dice sku present")
		return 1
	for sku in IapStub.catalog:
		if IapStub.grants_daylight(str((sku as Dictionary).get("id", ""))):
			print("FAIL sku grants daylight")
			return 1
	print("ok  no_daylight_sku")
	return 0
