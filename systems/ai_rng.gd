extends Node
## Poker decisions only. Never used for shuffle, pockets, reels, or wheel.

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var session_seed: int = 0
var call_count: int = 0


func _ready() -> void:
	boot_seed()


func boot_seed() -> void:
	var crypto := Crypto.new()
	var bytes: PackedByteArray = crypto.generate_random_bytes(8)
	var n: int = 0
	for i in 8:
		n = (n << 8) | int(bytes[i])
	if n == 0:
		n = Time.get_ticks_usec()
	session_seed = n
	rng.seed = n
	call_count = 0


func setup_with_seed(p_seed: int) -> void:
	session_seed = p_seed
	rng.seed = p_seed
	call_count = 0


func rand_int(max_exclusive: int) -> int:
	if max_exclusive <= 0:
		return 0
	call_count += 1
	return rng.randi_range(0, max_exclusive - 1)


func rand_float() -> float:
	call_count += 1
	return rng.randf()


func randf_range(a: float, b: float) -> float:
	call_count += 1
	return rng.randf_range(a, b)
