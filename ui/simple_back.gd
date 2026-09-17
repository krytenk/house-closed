extends Control
## Shared interior: plate + back. Rooms override plate_key / back_to.

@export var plate_key: String = ""
@export var plate_text: String = ""
@export var body_key: String = ""
@export var back_to: String = "island"


func _ready() -> void:
	$Bg.color = Palette.CREAM
	if plate_text != "":
		$Plate.text = plate_text
	elif plate_key != "":
		$Plate.text = Game.text(plate_key)
	if body_key != "":
		$Body.text = Game.text(body_key)
	$FunOnly.text = Game.text("fun_only")
	$Back.text = Game.text("back")
	$Back.custom_minimum_size = Vector2(240, 56)
	$Back.pressed.connect(func() -> void:
		if back_to == "island" and Economy.in_table_room:
			Game.leave_chance_room()
		else:
			Game.goto(back_to)
	)
	if has_node("Odds"):
		$Odds.visible = true
