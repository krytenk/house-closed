extends RefCounted
class_name CoconutWheel

const COST := 5
const EXTRA_CAP := 2


static func slice_table() -> Array:
	var f := FileAccess.open("res://data/paytables/coconut_wheel.json", FileAccess.READ)
	if f == null:
		return []
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return []
	var expanded: Array = []
	for sl in (parsed as Dictionary).get("slices", []):
		var d: Dictionary = sl
		for _i in int(d.get("count", 0)):
			expanded.append(d)
	return expanded


static func pull(extra_used: int = 0) -> Dictionary:
	var slices: Array = slice_table()
	if slices.is_empty():
		return {"pays": 0, "spin_again": false}
	var idx: int = ChanceRng.rand_int(slices.size())
	var sl: Dictionary = slices[idx]
	var again: bool = bool(sl.get("spin_again", false))
	if again and extra_used >= EXTRA_CAP:
		again = false
	return {
		"index": idx,
		"id": sl.get("id", ""),
		"pays": int(sl.get("pays", 0)),
		"spin_again": again,
		"cost": COST,
	}


static func play() -> Dictionary:
	var total: int = 0
	var extra: int = 0
	var pulls: Array = []
	var p: Dictionary = pull(0)
	total += int(p.get("pays", 0))
	pulls.append(p)
	while bool(p.get("spin_again", false)) and extra < EXTRA_CAP:
		extra += 1
		p = pull(extra)
		total += int(p.get("pays", 0))
		pulls.append(p)
	return {
		"bet": COST,
		"total": total,
		"net": total - COST,
		"celebrate": total >= COST,
		"pulls": pulls,
		"extra_used": extra,
	}
