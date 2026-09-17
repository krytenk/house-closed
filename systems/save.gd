extends Node

const PATH := "user://save.json"
const SCHEMA := 1

var age_verified: bool = false
var disclaimer_accepted: bool = false
var first_run_complete: bool = false
var progress: Dictionary = {}
var copy: Dictionary = {}


func _ready() -> void:
	_load_copy()
	load_from_disk()
	apply_clocks()


func _load_copy() -> void:
	var f := FileAccess.open("res://data/copy.json", FileAccess.READ)
	if f == null:
		copy = {}
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		copy = parsed
	else:
		copy = {}


func text(key: String, subs: Dictionary = {}) -> String:
	var s: String = str(copy.get(key, key))
	for k in subs.keys():
		s = s.replace("{%s}" % str(k), str(subs[k]))
	return s


func default_progress() -> Dictionary:
	return {
		"token_tile": 0,
		"tide_parts": 0,
		"decor_points": 0,
		"postcards": 0,
		"postcard_bonus_paid": false,
		"postcard_day": "",
		"recipes": 0,
		"recipe_bonus_paid": false,
		"hold_em_hands": 0,
		"crank_day": "",
		"bungalow_slots": {},
		"owned_cosmetics": [],
		"suite_unlocked": true,
		"friend_notes": [],
		"host_buildings_intact": true,
		"shades_has_sunglasses": true,
	}


func reset_new_game() -> void:
	age_verified = false
	disclaimer_accepted = false
	first_run_complete = false
	progress = default_progress()
	Economy.reset_new_game()
	Daylight.reset_new_game()
	PlaySafe.reset_new_game()
	RegionPolicy.reset_new_game()
	IapStub.reset_new_game()


func load_from_disk() -> void:
	progress = default_progress()
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var d: Dictionary = parsed
	if int(d.get("schema_version", 0)) > SCHEMA:
		return
	age_verified = bool(d.get("age_verified", false))
	disclaimer_accepted = bool(d.get("disclaimer_accepted", false))
	first_run_complete = bool(d.get("first_run_complete", false))
	var p: Dictionary = d.get("progress", {})
	progress = default_progress()
	for k in p.keys():
		progress[k] = p[k]
	Economy.from_dict(d.get("economy", {}))
	Daylight.from_dict(d.get("daylight", {}))
	PlaySafe.from_dict(d.get("play_safe", {}))
	RegionPolicy.from_dict(d.get("region", {}))
	IapStub.from_dict(d.get("iap", {}))


func capture() -> Dictionary:
	return {
		"schema_version": SCHEMA,
		"age_verified": age_verified,
		"disclaimer_accepted": disclaimer_accepted,
		"first_run_complete": first_run_complete,
		"progress": progress,
		"economy": Economy.to_dict(),
		"daylight": Daylight.to_dict(),
		"play_safe": PlaySafe.to_dict(),
		"region": RegionPolicy.to_dict(),
		"iap": IapStub.to_dict(),
		"rng": ChanceRng.snapshot(),
	}


func write_disk() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(capture(), "  "))
	f.close()


func apply_clocks() -> void:
	Daylight.apply_clock()
	Economy.apply_clock()
	maybe_daily_postcard()


func maybe_daily_postcard() -> void:
	var today: String = Time.get_date_string_from_system()
	if str(progress.get("postcard_day", "")) == today:
		return
	progress["postcard_day"] = today
	add_postcard_fragment()


func add_postcard_fragment() -> void:
	var n: int = int(progress.get("postcards", 0))
	if n < 12:
		progress["postcards"] = n + 1
	if int(progress.get("postcards", 0)) >= 12 and not bool(progress.get("postcard_bonus_paid", false)):
		progress["postcard_bonus_paid"] = true
		Economy.add_shells(200)


func add_recipe() -> void:
	var n: int = int(progress.get("recipes", 0))
	if n < 8:
		progress["recipes"] = n + 1


func grant_tide_part() -> bool:
	var n: int = int(progress.get("tide_parts", 0))
	if n >= 6:
		return false
	progress["tide_parts"] = n + 1
	return true


func delete_local() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	reset_new_game()
