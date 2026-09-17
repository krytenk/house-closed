extends Control


func _ready() -> void:
	if not Save.age_verified:
		Game.goto("age_gate")
		return
	$FunOnly.text = Game.text("fun_only")
	$Title.text = Game.text("disclaimer_title")
	$Body.text = Game.text("disclaimer_body")
	$Ack.text = Game.text("disclaimer_ack")
	$Continue.text = Game.text("disclaimer_continue")
	$Continue.disabled = true
	$Continue.custom_minimum_size = Vector2(320, 56)
	$Ack.toggled.connect(_on_ack)
	$Continue.pressed.connect(_on_continue)


func _on_ack(pressed: bool) -> void:
	$Continue.disabled = not pressed


func _on_continue() -> void:
	if not $Ack.button_pressed:
		return
	Game.accept_disclaimer()
