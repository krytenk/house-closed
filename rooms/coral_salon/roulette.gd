extends RefCounted
class_name EuroRoulette
## 37 pockets. Visual is theater. Result = ChanceRng.rand_int(37).

const REDS := [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]


static func spin() -> int:
	return ChanceRng.roulette_pocket()


static func color_of(n: int) -> String:
	if n == 0:
		return "green"
	if REDS.has(n):
		return "red"
	return "black"


static func settle(pocket: int, bets: Array) -> Dictionary:
	## bets: [{type, n, amount}] types: straight, split, street, corner, line6, column, dozen, red, black, odd, even, low, high
	var pay: int = 0
	var stake: int = 0
	for b in bets:
		var d: Dictionary = b
		var amt: int = int(d.get("amount", 0))
		stake += amt
		pay += _eval(pocket, d, amt)
	return {"pocket": pocket, "stake": stake, "pay": pay, "net": pay - stake, "celebrate": pay >= stake}


static func _eval(pocket: int, bet: Dictionary, amt: int) -> int:
	var t: String = str(bet.get("type", ""))
	match t:
		"straight":
			if pocket == int(bet.get("n", -1)):
				return amt * 36
		"split":
			if int(bet.get("n", -1)) == pocket or int(bet.get("n2", -1)) == pocket:
				return amt * 18
		"street":
			var start: int = int(bet.get("n", 0))
			if pocket >= start and pocket < start + 3 and pocket != 0:
				return amt * 12
		"corner":
			var nums: Array = bet.get("nums", [])
			if nums.has(pocket):
				return amt * 9
		"line6":
			var s: int = int(bet.get("n", 0))
			if pocket >= s and pocket < s + 6 and pocket != 0:
				return amt * 6
		"column":
			var col: int = int(bet.get("n", 1))
			if pocket != 0 and ((pocket - 1) % 3) + 1 == col:
				return amt * 3
		"dozen":
			var dz: int = int(bet.get("n", 1))
			if pocket >= 1 + (dz - 1) * 12 and pocket <= dz * 12:
				return amt * 3
		"red":
			if pocket != 0 and color_of(pocket) == "red":
				return amt * 2
		"black":
			if pocket != 0 and color_of(pocket) == "black":
				return amt * 2
		"odd":
			if pocket != 0 and pocket % 2 == 1:
				return amt * 2
		"even":
			if pocket != 0 and pocket % 2 == 0:
				return amt * 2
		"low":
			if pocket >= 1 and pocket <= 18:
				return amt * 2
		"high":
			if pocket >= 19 and pocket <= 36:
				return amt * 2
	return 0
