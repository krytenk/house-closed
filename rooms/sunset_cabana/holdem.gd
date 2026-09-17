extends RefCounted
class_name Holdem
## 6-max Hold'em. Shuffle via ChanceRng. 0 rake.

const BLINDS_SB := 25
const BLINDS_BB := 50
const SNG_BUYIN := 500
const SNG_PAY := [300, 150, 50]


static func deal_table(seats: int = 6) -> Dictionary:
	var d: Array = Cards.shuffled()
	var holes: Array = []
	for _s in seats:
		holes.append([d.pop_back(), d.pop_back()])
	return {"deck": d, "holes": holes, "board": []}


static func burn_and_flop(st: Dictionary) -> void:
	var d: Array = st["deck"]
	d.pop_back()
	st["board"] = [d.pop_back(), d.pop_back(), d.pop_back()]
	st["deck"] = d


static func burn_and_one(st: Dictionary) -> void:
	var d: Array = st["deck"]
	d.pop_back()
	(st["board"] as Array).append(d.pop_back())
	st["deck"] = d


static func winner_index(holes: Array, board: Array, alive: Array) -> int:
	var best: int = -1
	var best_i: int = int(alive[0])
	for i in alive:
		var cards: Array = (holes[i] as Array).duplicate()
		cards.append_array(board)
		var s: int = HandRank.best7(cards)
		if s > best:
			best = s
			best_i = int(i)
	return best_i
