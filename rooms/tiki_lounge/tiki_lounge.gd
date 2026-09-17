extends Control

var bet: int = 1
var last: Dictionary = {}


func _ready() -> void:
	$Plate.text = Game.text("door_slots_plate")
	$FunOnly.text = Game.text("fun_only")
	$Coming.text = Game.text("coming_next_tide")
	$Odds.text = "Palm Reels 20 lines · RTP 96.0%  |  Wheel 5 Shells · RTP 95.5%  |  Dive clusters · RTP 96.2%"
	$Back.custom_minimum_size = Vector2(240, 56)
	$Back.pressed.connect(func() -> void: Game.leave_chance_room())
	$Bet1.pressed.connect(func() -> void: bet = 1; _hud())
	$Bet5.pressed.connect(func() -> void: bet = 5; _hud())
	$Bet25.pressed.connect(func() -> void: bet = 25; _hud())
	$Bet50.pressed.connect(func() -> void: bet = 50; _hud())
	$Palm.pressed.connect(_palm)
	$Wheel.pressed.connect(_wheel)
	$Dive.pressed.connect(_dive)
	for b in [$Bet1, $Bet5, $Bet25, $Bet50, $Palm, $Wheel, $Dive]:
		b.custom_minimum_size = Vector2(200, 52)
	_hud()


func _hud() -> void:
	$Credits.text = "Credits %d   bet %d" % [Economy.hud_amount(), bet]


func _palm() -> void:
	if not _stake(bet):
		return
	last = PalmReels.play(bet)
	_pay(last)


func _wheel() -> void:
	if not _stake(CoconutWheel.COST):
		return
	last = CoconutWheel.play()
	_pay(last)


func _dive() -> void:
	if not _stake(bet):
		return
	last = LagoonDive.play(bet)
	_pay(last)


func _stake(n: int) -> bool:
	if not PlaySafe.chance_staking_allowed():
		Game.toast(Game.text("cool_off_on"))
		return false
	if not Game.can_spin_or_deal():
		Game.toast(Game.text("daylight_returns"))
		return false
	if not Economy.spend_shells(n):
		$Result.text = "Not enough credits"
		return false
	Economy.record_spin(0)
	return true


func _pay(result: Dictionary) -> void:
	var total: int = int(result.get("total", 0))
	if total > 0:
		Economy.add_shells(total)
	$Result.text = "Returned %d   net %d" % [total, int(result.get("net", 0))]
	if not bool(result.get("celebrate", false)):
		$Jingle.text = ""
	else:
		$Jingle.text = "chime"
	_hud()
	Save.write_disk()
