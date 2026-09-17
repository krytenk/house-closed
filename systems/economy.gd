extends Node
## Shells — the only wallet. Table credits convert 1:1 in Lounge / Salon / cash Cabana.

const START_SHELLS := 1000
const DAILY_GRANT := 200
const DAILY_GRANT_CAP := 2000
const PORCH_DAILY := 25
const LOOKOUT_DAILY := 15
const POSTCARD_COMPLETE_BONUS := 200
const TIDE_CRANK_PAY := 40
const FLOOR := 0

var shells: int = START_SHELLS
var table_credits: int = 0
var in_table_room: bool = false
## Practice poker house credits. Never convert to Shells.
var practice_credits: int = 0
var last_daily_grant_date: String = ""
var last_porch_date: String = ""
var last_lookout_date: String = ""
var season_pass_until_unix: int = 0
var net_shells_today: int = 0
var spins_today: int = 0
var last_net_date: String = ""

var time_unix: Callable = func() -> int: return int(Time.get_unix_time_from_system())
var date_string: Callable = func() -> String: return Time.get_date_string_from_system()


func _ready() -> void:
	apply_clock()


func reset_new_game() -> void:
	shells = START_SHELLS
	table_credits = 0
	in_table_room = false
	practice_credits = 0
	last_daily_grant_date = str(date_string.call())
	last_porch_date = ""
	last_lookout_date = ""
	season_pass_until_unix = 0
	net_shells_today = 0
	spins_today = 0
	last_net_date = ""


func hud_amount() -> int:
	if in_table_room:
		return table_credits
	return shells


func apply_clock() -> void:
	_roll_net_day()
	var today: String = str(date_string.call())
	if last_daily_grant_date == today:
		return
	var hour: int = int(Time.get_datetime_dict_from_unix_time(int(time_unix.call())).get("hour", 8))
	## Local 08:00 grant. If we load after 08:00 and have not granted today, grant.
	if hour >= 8 and last_daily_grant_date != today:
		_daily_grant(today)


func _daily_grant(today: String) -> void:
	if shells < DAILY_GRANT_CAP:
		var extra: int = 0
		if int(time_unix.call()) < season_pass_until_unix:
			extra = 50
		add_shells(DAILY_GRANT + extra)
	last_daily_grant_date = today


func _roll_net_day() -> void:
	var today: String = str(date_string.call())
	if last_net_date != today:
		last_net_date = today
		net_shells_today = 0
		spins_today = 0


func add_shells(n: int) -> void:
	_roll_net_day()
	if in_table_room:
		table_credits = maxi(FLOOR, table_credits + n)
	else:
		shells = maxi(FLOOR, shells + n)
	net_shells_today += n


func spend_shells(n: int) -> bool:
	_roll_net_day()
	if n <= 0:
		return true
	if in_table_room:
		if table_credits < n:
			return false
		table_credits -= n
		net_shells_today -= n
		return true
	if shells < n:
		return false
	shells -= n
	net_shells_today -= n
	return true


func enter_table_room() -> void:
	if in_table_room:
		return
	table_credits = shells
	shells = 0
	in_table_room = true


func exit_table_room() -> void:
	if not in_table_room:
		return
	shells = table_credits
	table_credits = 0
	in_table_room = false


func porch_pass() -> int:
	var today: String = str(date_string.call())
	if last_porch_date == today:
		return 0
	last_porch_date = today
	add_shells(PORCH_DAILY)
	return PORCH_DAILY


func lookout_land() -> int:
	var today: String = str(date_string.call())
	if last_lookout_date == today:
		return 0
	last_lookout_date = today
	add_shells(LOOKOUT_DAILY)
	return LOOKOUT_DAILY


func record_spin(net: int) -> void:
	_roll_net_day()
	spins_today += 1
	net_shells_today += 0  ## net already applied via spend/add
	var _n := net
	_n = _n


func reality_check_net() -> int:
	_roll_net_day()
	return net_shells_today


func to_dict() -> Dictionary:
	return {
		"shells": shells,
		"table_credits": table_credits,
		"in_table_room": in_table_room,
		"practice_credits": practice_credits,
		"last_daily_grant_date": last_daily_grant_date,
		"last_porch_date": last_porch_date,
		"last_lookout_date": last_lookout_date,
		"season_pass_until_unix": season_pass_until_unix,
		"net_shells_today": net_shells_today,
		"spins_today": spins_today,
		"last_net_date": last_net_date,
	}


func from_dict(d: Dictionary) -> void:
	shells = int(d.get("shells", START_SHELLS))
	table_credits = int(d.get("table_credits", 0))
	in_table_room = bool(d.get("in_table_room", false))
	practice_credits = int(d.get("practice_credits", 0))
	last_daily_grant_date = str(d.get("last_daily_grant_date", ""))
	last_porch_date = str(d.get("last_porch_date", ""))
	last_lookout_date = str(d.get("last_lookout_date", ""))
	season_pass_until_unix = int(d.get("season_pass_until_unix", 0))
	net_shells_today = int(d.get("net_shells_today", 0))
	spins_today = int(d.get("spins_today", 0))
	last_net_date = str(d.get("last_net_date", ""))
