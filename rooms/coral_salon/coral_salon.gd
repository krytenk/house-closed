extends Control

var bets: Array = []
var last_pocket: int = -1


func _ready() -> void:
	$Plate.text = Game.text("door_roulette_plate")
	$FunOnly.text = Game.text("fun_only")
	$Edge.text = Game.text("house_edge_roulette")
	$Lila.text = "Lila"
	$Back.custom_minimum_size = Vector2(240, 56)
	$Back.pressed.connect(func() -> void: Game.leave_chance_room())
	$Red.pressed.connect(func() -> void: _add("red", 1))
	$Black.pressed.connect(func() -> void: _add("black", 1))
	$Spin.pressed.connect(_spin)
	for b in [$Red, $Black, $Spin]:
		b.custom_minimum_size = Vector2(200, 52)
	_hud()


func _add(t: String, amt: int) -> void:
	var stake: int = _stake_sum() + amt
	if stake > 50:
		$Result.text = "Max 50"
		return
	bets.append({"type": t, "amount": amt})
	_hud()


func _stake_sum() -> int:
	var s: int = 0
	for b in bets:
		s += int((b as Dictionary).get("amount", 0))
	return s


func _spin() -> void:
	if not PlaySafe.chance_staking_allowed():
		Game.toast(Game.text("cool_off_on"))
		return
	if not Game.can_spin_or_deal():
		Game.toast(Game.text("daylight_returns"))
		return
	if bets.is_empty():
		bets.append({"type": "red", "amount": 1})
	var stake: int = _stake_sum()
	if stake < 1:
		return
	if not Economy.spend_shells(stake):
		$Result.text = "Not enough credits"
		return
	last_pocket = EuroRoulette.spin()
	var settled: Dictionary = EuroRoulette.settle(last_pocket, bets)
	var pay: int = int(settled.get("pay", 0))
	if pay > 0:
		Economy.add_shells(pay)
	Economy.record_spin(int(settled.get("net", 0)))
	$Result.text = "Pocket %d  %s  pay %d" % [last_pocket, EuroRoulette.color_of(last_pocket), pay]
	if not bool(settled.get("celebrate", false)):
		$Jingle.text = ""
	else:
		$Jingle.text = "chime"
	bets = []
	_hud()
	Save.write_disk()


func _hud() -> void:
	$Credits.text = "Credits %d   stake %d" % [Economy.hud_amount(), _stake_sum()]
