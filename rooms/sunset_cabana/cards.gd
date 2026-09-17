extends RefCounted
class_name Cards

const RANKS := ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
const SUITS := ["c", "d", "h", "s"]


static func deck() -> Array:
	var d: Array = []
	for r in RANKS:
		for s in SUITS:
			d.append(r + s)
	return d


static func shuffled() -> Array:
	var d: Array = deck()
	ChanceRng.fisher_yates(d)
	return d


static func rank_i(card: String) -> int:
	if card.length() < 1:
		return 0
	return RANKS.find(card.left(1))


static func suit(card: String) -> String:
	if card.length() < 2:
		return ""
	return card.substr(1, 1)
