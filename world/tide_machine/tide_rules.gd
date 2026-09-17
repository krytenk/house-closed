extends RefCounted
class_name TideRules
## Not Hasbro IP. Never name it Mouse Trap in UI. Parts never sold.

const PART_ORDER := [
	"CRANK_GEARS",
	"FLIP_FLOP_POST",
	"BUCKET_STAIRS",
	"GUTTER",
	"CRAB_BOARD",
	"UMBRELLA_CAGE",
]
const CRANK_SECONDS := 8.0
const PAY := 40


static func parts() -> int:
	return int(Save.progress.get("tide_parts", 0))


static func complete() -> bool:
	return parts() >= 6


static func can_buy_part() -> bool:
	return false


static func crank() -> Dictionary:
	if not complete():
		Game.toast(Save.text("tide_unfinished"))
		return {
			"ok": false,
			"complete": false,
			"prize": 0,
			"shop": false,
			"jam": true,
			"missing": PART_ORDER[parts()] if parts() < 6 else "",
		}
	var today: String = Time.get_date_string_from_system()
	var first_today: bool = str(Save.progress.get("crank_day", "")) != today
	Save.progress["crank_day"] = today
	Economy.add_shells(PAY)
	Save.add_postcard_fragment()
	Save.write_disk()
	return {
		"ok": true,
		"complete": true,
		"prize": PAY,
		"shop": false,
		"duration": CRANK_SECONDS,
		"unskippable": first_today,
		"postcard": true,
	}
