extends RefCounted


func run() -> int:
	ChanceRng.setup_with_seed(42)
	var counts := PackedInt32Array()
	counts.resize(37)
	counts.fill(0)
	for i in 37000:
		var p: int = ChanceRng.roulette_pocket()
		if p < 0 or p > 36:
			print("FAIL pocket out of range ", p)
			return 1
		counts[p] += 1
	for i in 37:
		if counts[i] == 0:
			print("FAIL pocket never hit ", i)
			return 1
	print("ok  european_roulette_37")
	return 0
