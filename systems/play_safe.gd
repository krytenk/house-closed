extends Node
## Session clock, spend caps, cool-off, self-exclude, reality check, delete.

const DAILY_CAP_DEFAULT := 15.0
const DAILY_CAP_MAX := 15.0
const WEEKLY_CAP_DEFAULT := 40.0
const RAISE_COOLOFF_SECONDS := 48 * 3600

var session_start_unix: int = 0
var last_clock_notice_min: int = 0
var daily_cap: float = DAILY_CAP_DEFAULT
var weekly_cap: float = WEEKLY_CAP_DEFAULT
var pending_daily_cap: float = -1.0
var pending_cap_unix: int = 0
var pending_weekly_cap: float = -1.0
var pending_weekly_unix: int = 0
var spent_today_usd: float = 0.0
var spent_week_usd: float = 0.0
var spend_day: String = ""
var spend_week_id: String = ""
var cool_off_until_unix: int = 0
var self_exclude_until_unix: int = 0  ## -1 = permanent
var full_lock: bool = false
var delete_requested_unix: int = 0

var time_unix: Callable = func() -> int: return int(Time.get_unix_time_from_system())
var date_string: Callable = func() -> String: return Time.get_date_string_from_system()


func _ready() -> void:
	if session_start_unix == 0:
		session_start_unix = int(time_unix.call())
	_roll_spend_windows()


func reset_new_game() -> void:
	session_start_unix = int(time_unix.call())
	last_clock_notice_min = 0
	daily_cap = DAILY_CAP_DEFAULT
	weekly_cap = WEEKLY_CAP_DEFAULT
	pending_daily_cap = -1.0
	pending_cap_unix = 0
	pending_weekly_cap = -1.0
	pending_weekly_unix = 0
	spent_today_usd = 0.0
	spent_week_usd = 0.0
	spend_day = ""
	spend_week_id = ""
	cool_off_until_unix = 0
	self_exclude_until_unix = 0
	full_lock = false
	delete_requested_unix = 0


func session_minutes() -> int:
	var now: int = int(time_unix.call())
	return int(maxi(0, now - session_start_unix) / 60)


func clock_notice_due() -> bool:
	var m: int = session_minutes()
	if m < 15:
		return false
	var bucket: int = int(m / 15) * 15
	if bucket > last_clock_notice_min:
		last_clock_notice_min = bucket
		return true
	return false


func _roll_spend_windows() -> void:
	var today: String = str(date_string.call())
	if spend_day != today:
		spend_day = today
		spent_today_usd = 0.0
	var week: String = _iso_week(today)
	if spend_week_id != week:
		spend_week_id = week
		spent_week_usd = 0.0
	if pending_daily_cap >= 0.0 and int(time_unix.call()) >= pending_cap_unix:
		daily_cap = pending_daily_cap
		pending_daily_cap = -1.0
		pending_cap_unix = 0
	if pending_weekly_cap >= 0.0 and int(time_unix.call()) >= pending_weekly_unix:
		weekly_cap = pending_weekly_cap
		pending_weekly_cap = -1.0
		pending_weekly_unix = 0


func _iso_week(date: String) -> String:
	## YYYY-MM-DD -> year-week. Simple: week = day-of-year / 7.
	var parts := date.split("-")
	if parts.size() < 3:
		return date
	var y: int = int(parts[0])
	var mo: int = int(parts[1])
	var d: int = int(parts[2])
	var unix: int = int(Time.get_unix_time_from_datetime_dict({"year": y, "month": mo, "day": d, "hour": 12, "minute": 0, "second": 0}))
	var doy: int = int(Time.get_datetime_dict_from_unix_time(unix).get("weekday", 0))
	var week: int = int((int(Time.get_unix_time_from_datetime_dict({"year": y, "month": mo, "day": d, "hour": 0, "minute": 0, "second": 0}) - Time.get_unix_time_from_datetime_dict({"year": y, "month": 1, "day": 1, "hour": 0, "minute": 0, "second": 0})) / 86400) / 7)
	var _w := doy
	_w = _w
	return "%d-W%d" % [y, week]


func set_daily_cap(value: float) -> void:
	value = clampf(value, 0.0, DAILY_CAP_MAX)
	if value <= daily_cap:
		daily_cap = value
		pending_daily_cap = -1.0
		pending_cap_unix = 0
		return
	pending_daily_cap = value
	pending_cap_unix = int(time_unix.call()) + RAISE_COOLOFF_SECONDS


func set_weekly_cap(value: float) -> void:
	value = maxf(0.0, value)
	if value <= weekly_cap:
		weekly_cap = value
		pending_weekly_cap = -1.0
		pending_weekly_unix = 0
		return
	pending_weekly_cap = value
	pending_weekly_unix = int(time_unix.call()) + RAISE_COOLOFF_SECONDS


func can_iap() -> bool:
	_roll_spend_windows()
	if is_cool_off():
		return false
	if is_self_excluded():
		return false
	if full_lock:
		return false
	return true


func can_spend(usd: float) -> bool:
	if not can_iap():
		return false
	_roll_spend_windows()
	if spent_today_usd + usd > daily_cap + 0.001:
		return false
	if spent_week_usd + usd > weekly_cap + 0.001:
		return false
	return true


func record_spend(usd: float) -> void:
	_roll_spend_windows()
	spent_today_usd += usd
	spent_week_usd += usd


func start_cool_off(seconds: int) -> void:
	cool_off_until_unix = int(time_unix.call()) + seconds


func is_cool_off() -> bool:
	if cool_off_until_unix <= 0:
		return false
	return int(time_unix.call()) < cool_off_until_unix


func start_self_exclude(seconds: int, p_full_lock: bool = false) -> void:
	if seconds < 0:
		self_exclude_until_unix = -1
	else:
		self_exclude_until_unix = int(time_unix.call()) + seconds
	full_lock = p_full_lock


func is_self_excluded() -> bool:
	if self_exclude_until_unix == -1:
		return true
	if self_exclude_until_unix <= 0:
		return false
	return int(time_unix.call()) < self_exclude_until_unix


func chance_staking_allowed() -> bool:
	if full_lock:
		return false
	if is_cool_off():
		return false
	if is_self_excluded():
		return false
	return true


func lounge_salon_human_allowed() -> bool:
	if full_lock:
		return false
	if is_self_excluded():
		return false
	return true


func practice_poker_allowed() -> bool:
	if full_lock:
		return false
	return true


func request_delete() -> void:
	delete_requested_unix = int(time_unix.call())


func to_dict() -> Dictionary:
	return {
		"session_start_unix": session_start_unix,
		"last_clock_notice_min": last_clock_notice_min,
		"daily_cap": daily_cap,
		"weekly_cap": weekly_cap,
		"pending_daily_cap": pending_daily_cap,
		"pending_cap_unix": pending_cap_unix,
		"pending_weekly_cap": pending_weekly_cap,
		"pending_weekly_unix": pending_weekly_unix,
		"spent_today_usd": spent_today_usd,
		"spent_week_usd": spent_week_usd,
		"spend_day": spend_day,
		"spend_week_id": spend_week_id,
		"cool_off_until_unix": cool_off_until_unix,
		"self_exclude_until_unix": self_exclude_until_unix,
		"full_lock": full_lock,
		"delete_requested_unix": delete_requested_unix,
	}


func from_dict(d: Dictionary) -> void:
	session_start_unix = int(d.get("session_start_unix", 0))
	last_clock_notice_min = int(d.get("last_clock_notice_min", 0))
	daily_cap = float(d.get("daily_cap", DAILY_CAP_DEFAULT))
	weekly_cap = float(d.get("weekly_cap", WEEKLY_CAP_DEFAULT))
	pending_daily_cap = float(d.get("pending_daily_cap", -1.0))
	pending_cap_unix = int(d.get("pending_cap_unix", 0))
	pending_weekly_cap = float(d.get("pending_weekly_cap", -1.0))
	pending_weekly_unix = int(d.get("pending_weekly_unix", 0))
	spent_today_usd = float(d.get("spent_today_usd", 0.0))
	spent_week_usd = float(d.get("spent_week_usd", 0.0))
	spend_day = str(d.get("spend_day", ""))
	spend_week_id = str(d.get("spend_week_id", ""))
	cool_off_until_unix = int(d.get("cool_off_until_unix", 0))
	self_exclude_until_unix = int(d.get("self_exclude_until_unix", 0))
	full_lock = bool(d.get("full_lock", false))
	delete_requested_unix = int(d.get("delete_requested_unix", 0))
