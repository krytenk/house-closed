extends Control


func _ready() -> void:
	$Title.text = "Lantern deck"
	$Body.text = Game.text("nightclub_preview")
	$Back.custom_minimum_size = Vector2(240, 56)
	$Back.pressed.connect(func() -> void: Game.goto("lobby"))
