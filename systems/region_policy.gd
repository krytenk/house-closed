extends Node
## No GPS. Do not false-block chance rooms except known WA.

var forced_region: String = ""  ## tests / settings: "US-WA", "CA-BC", "US-OR", ...
var locale_override: String = ""


func _ready() -> void:
	pass


func reset_new_game() -> void:
	forced_region = ""
	locale_override = ""


func locale() -> String:
	if locale_override != "":
		return locale_override
	return OS.get_locale()


func region_code() -> String:
	if forced_region != "":
		return forced_region
	var loc: String = locale()
	var upper: String = loc.to_upper()
	if upper.find("CA") != -1 and (upper.begins_with("EN_CA") or upper.begins_with("FR_CA") or upper.ends_with("_CA") or upper == "CA"):
		return "CA"
	return ""


func is_washington() -> bool:
	return region_code() == "US-WA"


func is_ca_locale() -> bool:
	var r: String = region_code()
	if r == "CA-BC" or r == "CA":
		return true
	var loc: String = locale().to_upper()
	return loc.begins_with("EN_CA") or loc.begins_with("FR_CA") or loc.ends_with("_CA")


func age_minimum() -> int:
	if is_ca_locale() or region_code() == "CA-BC":
		return 19
	return 18


func chance_rooms_open() -> bool:
	if is_washington():
		return false
	return true


func iap_open() -> bool:
	if is_washington():
		return false
	return true


func to_dict() -> Dictionary:
	return {"forced_region": forced_region, "locale_override": locale_override}


func from_dict(d: Dictionary) -> void:
	forced_region = str(d.get("forced_region", ""))
	locale_override = str(d.get("locale_override", ""))
