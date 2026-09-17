extends Node
## Movement token. Cap 40. Never sold. No SKU.

const CAP := 40
const REGEN_SECONDS := 180
const START := 40

var current: int = START
var last_regen_unix: int = 0
var last_topup_date: String = ""

var time_unix: Callable = func() -> int: return int(Time.get_unix_time_from_system())
var date_string: Callable = func() -> String: return Time.get_date_string_from_system()


func _ready() -> void:
	if last_regen_unix == 0:
		last_regen_unix = int(time_unix.call())
	apply_clock()


func reset_new_game() -> void:
	current = START
	last_regen_unix = int(time_unix.call())
	last_topup_date = str(date_string.call())


func apply_clock() -> void:
	_regen()
	_morning_topup()


func _regen() -> void:
	if current >= CAP:
		last_regen_unix = int(time_unix.call())
		return
	var now: int = int(time_unix.call())
	if last_regen_unix <= 0:
		last_regen_unix = now
		return
	var elapsed: int = now - last_regen_unix
	if elapsed < REGEN_SECONDS:
		return
	var ticks: int = int(elapsed / REGEN_SECONDS)
	current = mini(CAP, current + ticks)
	last_regen_unix += ticks * REGEN_SECONDS


func _morning_topup() -> void:
	var today: String = str(date_string.call())
	if last_topup_date == today:
		return
	var hour: int = int(Time.get_datetime_dict_from_unix_time(int(time_unix.call())).get("hour", 8))
	if hour >= 8:
		if current < CAP:
			current = CAP
		last_topup_date = today
		last_regen_unix = int(time_unix.call())


func can_walk() -> bool:
	apply_clock()
	return current > 0


func spend(steps: int) -> bool:
	apply_clock()
	if steps <= 0:
		return true
	if current < steps:
		return false
	current -= steps
	if current < CAP and last_regen_unix <= 0:
		last_regen_unix = int(time_unix.call())
	return true


func try_spend_up_to(rolled: int) -> int:
	apply_clock()
	if current <= 0:
		return 0
	var n: int = mini(rolled, current)
	current -= n
	return n


func to_dict() -> Dictionary:
	return {
		"current": current,
		"last_regen_unix": last_regen_unix,
		"last_topup_date": last_topup_date,
	}


func from_dict(d: Dictionary) -> void:
	current = int(d.get("current", START))
	last_regen_unix = int(d.get("last_regen_unix", 0))
	last_topup_date = str(d.get("last_topup_date", ""))
