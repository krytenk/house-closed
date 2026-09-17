extends Node3D
## Brown pelican, oversized sunglasses. Honk only. Never sells anything.


func has_sunglasses() -> bool:
	return bool(Save.progress.get("shades_has_sunglasses", true))
