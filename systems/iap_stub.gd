extends Node
## Desk shop only. Mock purchase for tests. MUST NOT call ChanceRng or mutate its seed.

var catalog: Array = []
var owned: PackedStringArray = PackedStringArray()
var first_iap_done: bool = false
var last_purchase_sku: String = ""
var last_error: String = ""
var purchases: Array = []  ## {sku, usd, unix}


func _ready() -> void:
	_load_catalog()


func _load_catalog() -> void:
	var path := "res://data/iap_skus.json"
	if not FileAccess.file_exists(path):
		catalog = []
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		catalog = []
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		catalog = []
		return
	catalog = (parsed as Dictionary).get("skus", [])


func reset_new_game() -> void:
	owned = PackedStringArray()
	first_iap_done = false
	last_purchase_sku = ""
	last_error = ""
	purchases = []


func sku_by_id(sku_id: String) -> Dictionary:
	for item in catalog:
		if str((item as Dictionary).get("id", "")) == sku_id:
			return item
	return {}


func grants_daylight(sku_id: String) -> bool:
	var sku: Dictionary = sku_by_id(sku_id)
	if sku.is_empty():
		return false
	if bool(sku.get("grants_daylight", false)):
		return true
	var idl: String = sku_id.to_lower()
	if idl.find("daylight") != -1 or idl.find("energy") != -1 or idl == "dice" or idl.find("dice_") != -1:
		return true
	return false


func any_sku_named_forbidden() -> bool:
	for item in catalog:
		var idl: String = str((item as Dictionary).get("id", "")).to_lower()
		if idl.find("daylight") != -1 or idl.find("energy") != -1 or idl == "dice" or idl.begins_with("dice"):
			return true
	return false


func can_purchase(sku_id: String) -> bool:
	last_error = ""
	if not RegionPolicy.iap_open():
		last_error = "region"
		return false
	if not PlaySafe.can_iap():
		last_error = "play_safe"
		return false
	if grants_daylight(sku_id):
		last_error = "forbidden"
		return false
	var sku: Dictionary = sku_by_id(sku_id)
	if sku.is_empty():
		last_error = "unknown"
		return false
	var usd: float = float(sku.get("price_usd", 0.0))
	if not PlaySafe.can_spend(usd):
		last_error = "cap"
		return false
	return true


func mock_purchase(sku_id: String, confirmed: bool = false) -> Dictionary:
	## Does not call ChanceRng. Does not mutate ChanceRng seed.
	if not can_purchase(sku_id):
		return {"ok": false, "error": last_error}
	if not first_iap_done and not confirmed:
		return {"ok": false, "error": "confirm", "copy_key": "first_iap_confirm"}
	var sku: Dictionary = sku_by_id(sku_id)
	var usd: float = float(sku.get("price_usd", 0.0))
	PlaySafe.record_spend(usd)
	first_iap_done = true
	last_purchase_sku = sku_id
	if not owned.has(sku_id):
		owned.append(sku_id)
	var shells_add: int = int(sku.get("grants_shells", 0))
	if shells_add > 0:
		Economy.add_shells(shells_add)
	var bonus: int = int(sku.get("daily_grant_bonus_shells", 0))
	var days: int = int(sku.get("duration_days", 0))
	if bonus > 0 and days > 0:
		Economy.season_pass_until_unix = int(Time.get_unix_time_from_system()) + days * 86400
	purchases.append({"sku": sku_id, "usd": usd, "unix": int(Time.get_unix_time_from_system())})
	Game.log_event("iap_sku", {"sku": sku_id})
	return {"ok": true, "sku": sku_id}


func to_dict() -> Dictionary:
	return {
		"owned": Array(owned),
		"first_iap_done": first_iap_done,
		"purchases": purchases,
	}


func from_dict(d: Dictionary) -> void:
	owned = PackedStringArray()
	for x in d.get("owned", []):
		owned.append(str(x))
	first_iap_done = bool(d.get("first_iap_done", false))
	purchases = d.get("purchases", [])
