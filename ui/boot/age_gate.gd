extends Control


func _ready() -> void:
	$FunOnly.text = Game.text("fun_only")
	var age: int = RegionPolicy.age_minimum()
	$Prompt.text = Game.text("age_prompt_19" if age >= 19 else "age_prompt_18")
	$Yes.text = Game.text("age_yes")
	$No.text = Game.text("age_no")
	$Yes.pressed.connect(_on_yes)
	$No.pressed.connect(_on_no)
	$Yes.custom_minimum_size = Vector2(280, 56)
	$No.custom_minimum_size = Vector2(280, 56)


func _on_yes() -> void:
	Game.accept_age()


func _on_no() -> void:
	$Denied.text = Game.text("age_denied")
	$Denied.visible = true
	$Yes.disabled = true
