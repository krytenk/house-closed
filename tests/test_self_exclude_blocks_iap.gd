extends RefCounted


func run() -> int:
	PlaySafe.reset_new_game()
	IapStub.reset_new_game()
	IapStub._load_catalog()
	PlaySafe.start_self_exclude(-1, false)
	if IapStub.can_purchase("shell_pack_small"):
		print("FAIL iap allowed during self-exclude")
		return 1
	if PlaySafe.lounge_salon_human_allowed():
		print("FAIL lounge allowed during self-exclude")
		return 1
	PlaySafe.reset_new_game()
	print("ok  self_exclude_blocks_iap")
	return 0
