extends Control


func _ready() -> void:
	$Title.text = Game.text("region_blocked_title")
	$Body.text = Game.text("wa_chance_block")
	$Back.custom_minimum_size = Vector2(280, 56)
	$Back.pressed.connect(func() -> void: Game.goto("island"))
