extends RefCounted


func run() -> int:
	RegionPolicy.forced_region = "US-WA"
	if RegionPolicy.chance_rooms_open():
		print("FAIL WA chance open")
		return 1
	if RegionPolicy.iap_open():
		print("FAIL WA iap open")
		return 1
	RegionPolicy.forced_region = ""
	RegionPolicy.locale_override = "en_CA"
	if RegionPolicy.age_minimum() != 19:
		print("FAIL CA age")
		return 1
	RegionPolicy.locale_override = ""
	print("ok  region_wa")
	return 0
