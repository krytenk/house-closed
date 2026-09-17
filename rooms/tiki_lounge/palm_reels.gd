extends RefCounted
class_name PalmReels
## 5x3, 20 paylines always on. Result chosen on press, then animated.

const LINES: Array = [
	[1, 1, 1, 1, 1],
	[0, 0, 0, 0, 0],
	[2, 2, 2, 2, 2],
	[0, 1, 2, 1, 0],
	[2, 1, 0, 1, 2],
	[0, 0, 1, 2, 2],
	[2, 2, 1, 0, 0],
	[1, 2, 1, 0, 1],
	[1, 0, 1, 2, 1],
	[1, 0, 0, 0, 1],
	[1, 2, 2, 2, 1],
	[0, 1, 1, 1, 2],
	[2, 1, 1, 1, 0],
	[0, 1, 2, 2, 2],
	[2, 1, 0, 0, 0],
	[1, 1, 0, 1, 1],
	[1, 1, 2, 1, 1],
	[0, 0, 1, 0, 0],
	[2, 2, 1, 2, 2],
	[0, 2, 1, 2, 0],
]

const PAY := {
	"W": {5: 50, 4: 15, 3: 5},
	"P": {5: 25, 4: 8, 3: 3},
	"C": {5: 20, 4: 6, 3: 2},
	"H": {5: 12, 4: 4, 3: 2},
	"S": {5: 8, 4: 3, 3: 1},
	"L": {5: 5, 4: 2, 3: 1},
}

const SCATTER_PAY := {3: 1, 4: 3, 5: 10}
const BETS := [1, 5, 25, 50]

static var strips: Array = []
static var loaded: bool = false


static func load_table() -> void:
	if loaded:
		return
	var f := FileAccess.open("res://data/paytables/palm_reels.json", FileAccess.READ)
	if f == null:
		strips = _fallback_strips()
		loaded = true
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		strips = (parsed as Dictionary).get("strips", [])
	if strips.size() != 5:
		strips = _fallback_strips()
	loaded = true


static func _fallback_strips() -> Array:
	## 32-stop teaching strips. RTP search overwrites JSON; this is a compile fallback.
	return [
		["L","L","S","P","L","H","C","L","S","W","L","P","H","L","S","C","L","B","L","H","S","L","P","C","L","S","H","L","P","L","C","S"],
		["L","S","L","C","H","L","P","S","L","C","L","H","S","W","L","P","L","C","S","L","H","B","L","S","P","L","C","H","L","S","L","P"],
		["S","L","H","L","C","P","L","S","L","H","C","L","S","P","L","W","L","S","H","L","C","L","B","S","L","P","H","L","C","S","L","H"],
		["L","C","S","L","H","L","P","S","C","L","H","L","S","P","L","C","W","L","S","H","L","B","P","L","S","C","L","H","S","L","P","L"],
		["L","S","P","L","C","H","L","S","L","P","C","L","S","H","L","P","S","L","C","B","L","H","S","L","P","W","L","C","S","L","H","L"],
	]


static func spin(bet: int, wild_mult: int = 1) -> Dictionary:
	load_table()
	var stops: Array = []
	var window: Array = []  ## 5 cols of 3
	for r in 5:
		var strip: Array = strips[r]
		var st: int = ChanceRng.rand_int(strip.size())
		stops.append(st)
		var col: Array = []
		for row in 3:
			col.append(str(strip[(st + row) % strip.size()]))
		window.append(col)
	return evaluate(window, bet, wild_mult, stops)


static func evaluate(window: Array, bet: int, wild_mult: int, stops: Array) -> Dictionary:
	var line_win: int = 0
	for line in LINES:
		line_win += _line_pay(window, line, bet, wild_mult)
	var scatters: int = 0
	for col in window:
		for sym in col:
			if str(sym) == "B":
				scatters += 1
	var scatter_win: int = 0
	if SCATTER_PAY.has(scatters):
		scatter_win = int(SCATTER_PAY[scatters]) * bet
	elif scatters > 5:
		scatter_win = int(SCATTER_PAY[5]) * bet
	var fs: int = 0
	if scatters >= 3:
		fs = 8
	var total: int = line_win + scatter_win
	return {
		"window": window,
		"stops": stops,
		"line_win": line_win,
		"scatter_win": scatter_win,
		"scatters": scatters,
		"free_spins": fs,
		"total": total,
		"net": total - bet,
		"celebrate": total >= bet,
	}


static func _line_pay(window: Array, line: Array, bet: int, wild_mult: int) -> int:
	var seq: Array = []
	for i in 5:
		seq.append(str(window[i][line[i]]))
	var face: String = ""
	var count: int = 0
	var used_wild: bool = false
	for i in 5:
		var s: String = str(seq[i])
		if s == "B":
			break
		if s == "W":
			used_wild = true
			count += 1
			continue
		if face == "":
			face = s
			count += 1
			continue
		if s == face:
			count += 1
			continue
		break
	if face == "" and count >= 3:
		face = "W"
	if face == "" or count < 3:
		return 0
	if not PAY.has(face):
		return 0
	var table: Dictionary = PAY[face]
	if not table.has(count):
		if count > 5:
			count = 5
		if not table.has(count):
			return 0
	var mult: int = int(table[count])
	if used_wild:
		mult *= wild_mult
	return mult * bet


static func play(bet: int) -> Dictionary:
	## Includes free-spin sequence. Result fully determined here.
	var first: Dictionary = spin(bet, 1)
	var total: int = int(first.get("total", 0))
	var extra: int = int(first.get("free_spins", 0))
	var cap: int = 20
	var played_fs: int = 0
	while extra > 0 and played_fs < cap:
		extra -= 1
		played_fs += 1
		var fs: Dictionary = spin(bet, 2)
		total += int(fs.get("total", 0))
		var more: int = 0
		if int(fs.get("scatters", 0)) >= 3:
			more = 2
		extra = mini(cap - played_fs, extra + more)
	return {
		"bet": bet,
		"total": total,
		"net": total - bet,
		"celebrate": total >= bet,
		"first": first,
		"free_spins_played": played_fs,
	}
