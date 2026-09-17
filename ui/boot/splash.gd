extends Control

var _advanced: bool = false


func _ready() -> void:
	$FunOnly.text = Game.text("fun_only")
	$Title.text = "PALM ATOLL"
	get_tree().create_timer(1.8).timeout.connect(_advance)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("walk"):
		_advance()
	if event is InputEventMouseButton and event.pressed:
		_advance()
	if event is InputEventScreenTouch and event.pressed:
		_advance()


func _advance() -> void:
	if _advanced:
		return
	_advanced = true
	Game.advance_boot()
