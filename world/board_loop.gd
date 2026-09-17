extends Node3D
## 24-tile clockwise loop. Fair d6. Cost = tiles stepped. No multiplier. No paid x10.

const LOOP := 24

var tiles: Array = []
var token_tile: int = 0
var last_die: int = 0
var last_land: Dictionary = {}
var standing_since_land: bool = false


func _ready() -> void:
	add_to_group("board_loop")
	_load_tiles()
	token_tile = int(Save.progress.get("token_tile", 0))


func _load_tiles() -> void:
	var f := FileAccess.open("res://data/tile_defs.json", FileAccess.READ)
	if f == null:
		tiles = []
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		tiles = (parsed as Dictionary).get("tiles", [])
	else:
		tiles = []


func tile_at(i: int) -> Dictionary:
	if tiles.is_empty():
		return {}
	return tiles[i % LOOP]


func walk() -> Dictionary:
	Daylight.apply_clock()
	if Daylight.current <= 0:
		Game.toast(Save.text("daylight_returns"))
		return {"ok": false, "reason": "daylight", "shop": false}
	last_die = ChanceRng.die_d6()
	var steps: int = Daylight.try_spend_up_to(last_die)
	if steps <= 0:
		Game.toast(Save.text("daylight_returns"))
		return {"ok": false, "reason": "daylight", "shop": false, "die": last_die}
	for _s in steps:
		token_tile = (token_tile + 1) % LOOP
		if token_tile == 0:
			Economy.porch_pass()
	Save.progress["token_tile"] = token_tile
	standing_since_land = true
	last_land = _resolve_land(tile_at(token_tile))
	Save.write_disk()
	return {"ok": true, "die": last_die, "steps": steps, "tile": token_tile, "id": tile_at(token_tile).get("id", ""), "shop": false, "land": last_land}


func _resolve_land(tile: Dictionary) -> Dictionary:
	var result := {"id": tile.get("id", ""), "entered": false}
	var land: String = str(tile.get("land", ""))
	match land:
		"porch":
			pass
		"bungalow":
			Economy.add_shells(int(tile.get("shells", 10)))
			Save.progress["decor_points"] = int(Save.progress.get("decor_points", 0)) + int(tile.get("decor_points", 1))
		"rest":
			Economy.add_shells(int(tile.get("shells", 5)))
		"build":
			if not Save.grant_tide_part():
				Economy.add_shells(int(tile.get("shells_if_complete", 15)))
		"guest":
			Economy.add_shells(int(tile.get("shells", 10)))
			Save.add_postcard_fragment()
		"shades":
			Economy.add_shells(int(tile.get("shells", 10)))
			Save.progress["shades_has_sunglasses"] = not bool(Save.progress.get("shades_has_sunglasses", true))
			Game.toast(Save.text("shades_honk"))
		"splash":
			Economy.add_shells(int(tile.get("shells", 20)))
		"dock":
			Economy.add_shells(int(tile.get("shells", 10)))
			## MUST NOT raid or damage.
			Save.progress["host_buildings_intact"] = true
		"lookout":
			Economy.lookout_land()
		"crank":
			if int(Save.progress.get("tide_parts", 0)) < 6:
				Game.toast(Save.text("tide_need_parts"))
				Economy.add_shells(int(tile.get("incomplete_shells", 10)))
		"door":
			## Does not auto-launch. Second tap required.
			result["needs_tap"] = true
			result["tap"] = str(tile.get("tap", ""))
			result["label"] = str(tile.get("label", ""))
	return result


func tap_current() -> Dictionary:
	var tile: Dictionary = tile_at(token_tile)
	var tap: String = str(tile.get("tap", ""))
	if tap == "":
		return {"ok": false}
	if bool(tile.get("auto_launch", false)):
		## Spec: no tile auto-launches a chance game.
		return {"ok": false, "reason": "auto_forbidden"}
	if bool(tile.get("chance", false)):
		if not RegionPolicy.chance_rooms_open():
			Game.toast(Save.text("wa_chance_block"))
			return {"ok": false, "reason": "region"}
		if not PlaySafe.lounge_salon_human_allowed() and tap in ["lounge", "salon", "cabana"]:
			Game.toast(Save.text("self_exclude_on"))
			return {"ok": false, "reason": "self_exclude"}
	match tap:
		"house":
			Game.goto("lobby")
		"lounge":
			Game.enter_chance_room("lounge")
		"cabana":
			Game.goto("cabana")  ## sit flow chooses HUMAN vs PRACTICE before credits move
		"salon":
			Game.enter_chance_room("salon")
		"jetski":
			if not Game.can_start_mini():
				Game.toast(Save.text("daylight_returns"))
				return {"ok": false, "reason": "daylight", "shop": false}
			Game.goto("jetski")
		"coconut_shy":
			if not Game.can_start_mini():
				Game.toast(Save.text("daylight_returns"))
				return {"ok": false, "reason": "daylight", "shop": false}
			Game.goto("coconut_shy")
		"decorate":
			Game.goto("bungalow")
		"nightclub":
			Game.goto("nightclub")
		"visit":
			Game.toast(Save.text("friend_dock_note"))
		"crank":
			return crank()
	return {"ok": true, "tap": tap}


func crank() -> Dictionary:
	return TideRules.crank()
