extends Control

const SLOTS := ["bed", "lamp", "rug", "window_drape", "chair", "plant", "wall_art", "nightstand"]


func _ready() -> void:
	$Title.text = "BUNGALOW"
	$Note.text = "Cosmetics only. No stat bonuses."
	$Back.custom_minimum_size = Vector2(240, 56)
	$Back.pressed.connect(func() -> void: Game.goto("island"))
	var slots: Dictionary = Save.progress.get("bungalow_slots", {})
	var y := 180
	for s in SLOTS:
		var b := Button.new()
		b.text = s
		b.toggle_mode = true
		b.button_pressed = bool(slots.get(s, false))
		b.position = Vector2(80, y)
		b.custom_minimum_size = Vector2(320, 52)
		b.toggled.connect(_toggle.bind(s))
		add_child(b)
		y += 64
	$Corridor.text = "Nia · Arthur · Jules — not enterable"


func _toggle(on: bool, slot: String) -> void:
	var slots: Dictionary = Save.progress.get("bungalow_slots", {})
	slots[slot] = on
	Save.progress["bungalow_slots"] = slots
	Save.write_disk()
