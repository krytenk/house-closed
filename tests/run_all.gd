extends SceneTree

var fails: int = 0


func _init() -> void:
	call_deferred("_go")


func _go() -> void:
	var save: Node = root.get_node("Save")
	var iap: Node = root.get_node("IapStub")
	save.call("reset_new_game")
	iap.call("_load_catalog")
	fails += _run("res://tests/test_no_daylight_sku.gd")
	fails += _run("res://tests/test_single_currency_strings.gd")
	fails += _run("res://tests/test_daylight_zero_no_shop_modal.gd")
	fails += _run("res://tests/test_self_exclude_blocks_iap.gd")
	fails += _run("res://tests/test_european_roulette_37.gd")
	fails += _run("res://tests/test_tide_machine_incomplete_no_prize.gd")
	fails += _run("res://tests/test_tide_machine_complete_pays_40.gd")
	fails += _run("res://tests/test_purchase_does_not_change_slots.gd")
	fails += _run("res://tests/test_purchase_does_not_change_poker_ai.gd")
	fails += _run("res://tests/test_ai_cannot_read_other_hole_cards.gd")
	fails += _run("res://tests/test_board_and_economy.gd")
	fails += _run("res://tests/test_region_wa.gd")
	fails += _run("res://tests/test_session_t1.gd")
	print("PALM_ATOLL_TESTS fails=", fails)
	quit(fails)


func _run(path: String) -> int:
	var scr: Script = load(path)
	if scr == null:
		push_error("MISSING " + path)
		print("FAIL missing ", path)
		return 1
	var inst: Object = scr.new()
	if inst.has_method("run"):
		var n: int = int(inst.call("run"))
		if inst is Node:
			(inst as Node).free()
		return n
	print("FAIL no run() ", path)
	return 1
