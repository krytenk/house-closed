extends RefCounted
class_name PokerAI
## Sees only its hole cards + board. NEVER other hole cards. NEVER future streets.
## Decisions use AiRng only.

const STYLES := ["Reef", "Breaker", "Lagoon"]


static func decide(style: String, hole: Array, board: Array, to_call: int, pot: int, stack: int, can_raise: bool) -> String:
	## Returns fold | call | raise. No other-seat inputs exist on this API.
	var strength: float = _strength(hole, board)
	var r: float = AiRng.rand_float()
	match style:
		"Reef":
			## Tight-passive.
			if to_call == 0:
				if can_raise and strength > 0.82 and r < 0.15:
					return "raise"
				return "call"
			if strength < 0.55:
				return "fold"
			if strength < 0.8 or r > 0.08:
				return "call"
			return "raise" if can_raise else "call"
		"Breaker":
			## Loose-aggressive. Steals, c-bets, folds to 3-bet without equity.
			if to_call == 0:
				if can_raise and r < 0.55:
					return "raise"
				return "call"
			if to_call > pot and strength < 0.62:
				return "fold"
			if strength < 0.35 and r > 0.25:
				return "fold"
			if can_raise and r < 0.45:
				return "raise"
			return "call"
		_:
			## Lagoon: tight-aggressive ABC + small bluff on missed boards.
			if to_call == 0:
				if can_raise and (strength > 0.7 or (board.size() >= 3 and strength < 0.35 and r < 0.12)):
					return "raise"
				return "call"
			if strength < 0.5:
				return "fold"
			if can_raise and strength > 0.78:
				return "raise"
			return "call"
	var _p := pot
	var _s := stack
	_p = _p
	_s = _s
	return "call"


static func _strength(hole: Array, board: Array) -> float:
	var cards: Array = hole.duplicate()
	cards.append_array(board)
	if cards.size() < 2:
		return 0.0
	if board.is_empty():
		return _preflop(hole)
	var score: int = HandRank.best7(cards)
	return clampf(float(score) / 9000000.0, 0.0, 1.0)


static func _preflop(hole: Array) -> float:
	if hole.size() < 2:
		return 0.0
	var a: int = Cards.rank_i(str(hole[0]))
	var b: int = Cards.rank_i(str(hole[1]))
	var pair: bool = a == b
	var suited: bool = Cards.suit(str(hole[0])) == Cards.suit(str(hole[1]))
	var hi: int = maxi(a, b)
	var lo: int = mini(a, b)
	var s: float = float(hi) / 12.0 * 0.55 + float(lo) / 12.0 * 0.2
	if pair:
		s += 0.28
	if suited:
		s += 0.06
	return clampf(s, 0.05, 0.99)


static func think_delay() -> float:
	return AiRng.randf_range(1.2, 3.5)
