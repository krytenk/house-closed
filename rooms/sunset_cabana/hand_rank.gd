extends RefCounted
class_name HandRank
## 7-card rank. Higher score is better. Score is comparable int.


static func best7(cards: Array) -> int:
	if cards.size() < 5:
		return 0
	if cards.size() == 5:
		return _five(cards)
	return _combo(cards, 5, [], 0, 0)


static func _combo(cards: Array, need: int, cur: Array, start: int, best: int) -> int:
	if cur.size() == need:
		var s: int = _five(cur)
		if s > best:
			best = s
		return best
	for i in range(start, cards.size()):
		cur.append(cards[i])
		best = _combo(cards, need, cur, i + 1, best)
		cur.pop_back()
	return best


static func _five(cards: Array) -> int:
	var ranks: Array = []
	var suits: Array = []
	for c in cards:
		ranks.append(Cards.rank_i(str(c)))
		suits.append(Cards.suit(str(c)))
	ranks.sort()
	var flush: bool = true
	for i in range(1, 5):
		if suits[i] != suits[0]:
			flush = false
			break
	var straight: bool = _straight(ranks)
	var counts := {}
	for r in ranks:
		counts[r] = int(counts.get(r, 0)) + 1
	var freqs: Array = counts.values()
	freqs.sort()
	var cat: int = 0
	if flush and straight:
		cat = 8
	elif freqs == [1, 4] or (freqs.size() == 2 and freqs.max() == 4):
		cat = 7
	elif freqs.has(3) and freqs.has(2):
		cat = 6
	elif flush:
		cat = 5
	elif straight:
		cat = 4
	elif freqs.has(3):
		cat = 3
	elif freqs.count(2) == 2 or _two_pair(counts):
		cat = 2
	elif freqs.has(2):
		cat = 1
	else:
		cat = 0
	var kick: int = 0
	var rs: Array = ranks.duplicate()
	rs.reverse()
	for r in rs:
		kick = kick * 16 + int(r)
	return cat * 1000000 + kick


static func _two_pair(counts: Dictionary) -> bool:
	var n: int = 0
	for k in counts.keys():
		if int(counts[k]) == 2:
			n += 1
	return n >= 2


static func _straight(sorted_ranks: Array) -> bool:
	var u: Array = []
	for r in sorted_ranks:
		if u.is_empty() or u.back() != r:
			u.append(r)
	if u.size() < 5:
		## wheel A2345: ranks contain 12 and 0,1,2,3
		if sorted_ranks.has(12) and sorted_ranks.has(0) and sorted_ranks.has(1) and sorted_ranks.has(2) and sorted_ranks.has(3):
			return true
		return false
	for i in range(u.size() - 4):
		if int(u[i + 4]) - int(u[i]) == 4:
			return true
	if u.has(12) and u.has(0) and u.has(1) and u.has(2) and u.has(3):
		return true
	return false
