extends Control


func _ready() -> void:
	$Title.text = "Odds"
	$Body.text = "Palm Reels RTP 96.0%\nCoconut Wheel RTP 95.5%\nLagoon Dive RTP 96.2%\nEuropean roulette house edge 2.70%.\nPrizes are set when the bonus starts.\nFOR FUN ONLY. YOU CANNOT WIN REAL MONEY."
	$Back.custom_minimum_size = Vector2(240, 56)
	$Back.pressed.connect(func() -> void: Game.goto("lounge"))
