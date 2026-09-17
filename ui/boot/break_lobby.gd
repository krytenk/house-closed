extends Control


func _ready() -> void:
	$Msg.text = Game.text("taking_a_break")
	$PlaySafe.custom_minimum_size = Vector2(280, 56)
	$PlaySafe.pressed.connect(func() -> void: Game.goto("play_safe"))
