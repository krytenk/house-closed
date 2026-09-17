extends Node
## Sole source for slots, wheel, dive bonus, roulette pocket, board die, postcard draws, poker shuffle.
## IAP / shop / ads / spend-cap / VIP MUST NOT call this or mutate seed or tables.

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var session_seed: int = 0
var call_count: int = 0


func _ready() -> void:
	boot_seed()


func boot_seed() -> void:
	session_seed = _csprng_u64()
	rng.seed = session_seed
	call_count = 0
	_log_seed()


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


func weighted_index(weights: PackedInt32Array) -> int:
	var total: int = 0
	for w in weights:
		total += int(w)
	if total <= 0:
		return 0
	var roll: int = rand_int(total)
	var acc: int = 0
	for i in weights.size():
		acc += int(weights[i])
		if roll < acc:
			return i
	return weights.size() - 1


func die_d6() -> int:
	return rand_int(6) + 1


func roulette_pocket() -> int:
	## European: 0..36 inclusive, 37 pockets equal.
	return rand_int(37)


func fisher_yates(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j: int = rand_int(i + 1)
		var tmp: Variant = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


func snapshot() -> Dictionary:
	return {"session_seed": session_seed, "call_count": call_count}


func _csprng_u64() -> int:
	var crypto := Crypto.new()
	var bytes: PackedByteArray = crypto.generate_random_bytes(8)
	var n: int = 0
	for i in 8:
		n = (n << 8) | int(bytes[i])
	if n == 0:
		n = Time.get_unix_time_from_system()
	return n


func _log_seed() -> void:
	var path := "user://session_seed.log"
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return
	f.store_line("%s seed=%d" % [Time.get_datetime_string_from_system(), session_seed])
	f.close()
