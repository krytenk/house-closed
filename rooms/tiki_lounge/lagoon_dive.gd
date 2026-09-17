extends RefCounted
class_name LagoonDive

const FISH := ["A", "B", "C", "D", "E"]
const CHEST := "T"
const MAX_CASCADES := 8
const CLUSTER_PAY := {
	5: 1,
	6: 2,
	7: 2,
	8: 4,
	9: 4,
	10: 8,
	11: 8,
	12: 8,
	13: 20,
	14: 20,
	15: 20,
}

static var weights: PackedInt32Array = PackedInt32Array([22, 22, 20, 16, 12, 3])  ## 5 fish + chest
static var loaded: bool = false


static func load_table() -> void:
	if loaded:
		return
	var f := FileAccess.open("res://data/paytables/lagoon_dive.json", FileAccess.READ)
	if f != null:
		var parsed: Variant = JSON.parse_string(f.get_as_text())
		f.close()
		if typeof(parsed) == TYPE_DICTIONARY:
			var w: Array = (parsed as Dictionary).get("weights", [])
			if w.size() == 6:
				weights = PackedInt32Array()
				for x in w:
					weights.append(int(x))
	loaded = true


static func _sym() -> String:
	var i: int = ChanceRng.weighted_index(weights)
	if i >= 5:
		return CHEST
	return FISH[i]


static func play(bet: int) -> Dictionary:
	load_table()
	var grid: Array = []
	for r in 3:
		var row: Array = []
		for c in 5:
			row.append(_sym())
		grid.append(row)
	var total: int = 0
	var cascades: int = 0
	var chest_count: int = 0
	for r in 3:
		for c in 5:
			if str(grid[r][c]) == CHEST:
				chest_count += 1
	var bonus: int = 0
	if chest_count >= 3:
		bonus = _chests(bet)
	while cascades < MAX_CASCADES:
		var clusters: Array = _clusters(grid)
		if clusters.is_empty():
			break
		var pay_mult: float = 0.0
		var pop: Dictionary = {}
		for cl in clusters:
			var n: int = (cl as Array).size()
			if n < 5:
				continue
			var key: int = n
			if key > 15:
				key = 15
			pay_mult += float(CLUSTER_PAY.get(key, 0))
			for cell in cl:
				pop["%d,%d" % [cell[0], cell[1]]] = true
		if pop.is_empty():
			break
		var cascade_mult: float = 1.0 + 0.2 * float(cascades)
		total += int(round(pay_mult * float(bet) * cascade_mult))
		_pop_and_drop(grid, pop)
		cascades += 1
	total += bonus
	return {
		"bet": bet,
		"total": total,
		"net": total - bet,
		"celebrate": total >= bet,
		"cascades": cascades,
		"chests": chest_count,
		"bonus": bonus,
	}


static func _clusters(grid: Array) -> Array:
	var seen := {}
	var out: Array = []
	for r in 3:
		for c in 5:
			var k := "%d,%d" % [r, c]
			if seen.has(k):
				continue
			var sym: String = str(grid[r][c])
			if sym == CHEST:
				continue
			var stack: Array = [[r, c]]
			var cells: Array = []
			seen[k] = true
			while not stack.is_empty():
				var cur: Array = stack.pop_back()
				cells.append(cur)
				var dirs := [[1, 0], [-1, 0], [0, 1], [0, -1]]
				for d in dirs:
					var nr: int = int(cur[0]) + int(d[0])
					var nc: int = int(cur[1]) + int(d[1])
					if nr < 0 or nr > 2 or nc < 0 or nc > 4:
						continue
					var nk := "%d,%d" % [nr, nc]
					if seen.has(nk):
						continue
					if str(grid[nr][nc]) != sym:
						continue
					seen[nk] = true
					stack.append([nr, nc])
			if cells.size() >= 5:
				out.append(cells)
	return out


static func _pop_and_drop(grid: Array, pop: Dictionary) -> void:
	for c in 5:
		var keep: Array = []
		for r in range(2, -1, -1):
			var k := "%d,%d" % [r, c]
			if pop.has(k):
				continue
			keep.append(str(grid[r][c]))
		while keep.size() < 3:
			keep.append(_sym())
		for r in 3:
			grid[2 - r][c] = keep[r]


static func _chests(bet: int) -> int:
	var f := FileAccess.open("res://data/paytables/lagoon_dive_chests.json", FileAccess.READ)
	var table: Array = [
		{"prize_x_bet": 1, "weight": 30},
		{"prize_x_bet": 2, "weight": 25},
		{"prize_x_bet": 3, "weight": 20},
		{"prize_x_bet": 5, "weight": 15},
		{"prize_x_bet": 8, "weight": 7},
		{"prize_x_bet": 15, "weight": 3},
	]
	if f != null:
		var parsed: Variant = JSON.parse_string(f.get_as_text())
		f.close()
		if typeof(parsed) == TYPE_DICTIONARY:
			table = (parsed as Dictionary).get("table", table)
	var w := PackedInt32Array()
	for row in table:
		w.append(int((row as Dictionary).get("weight", 0)))
	var total: int = 0
	for _i in 3:
		var idx: int = ChanceRng.weighted_index(w)
		total += int((table[idx] as Dictionary).get("prize_x_bet", 1)) * bet
	return total
