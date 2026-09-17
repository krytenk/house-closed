extends Control


func _ready() -> void:
	$Title.text = "Postcards"
	var n: int = int(Save.progress.get("postcards", 0))
	$Count.text = "%d/12" % n
	$Back.custom_minimum_size = Vector2(240, 56)
	$Back.pressed.connect(func() -> void: Game.goto("lobby"))
	var names := ["Porch dawn", "Lagoon", "Marina", "Pelican", "Lanterns", "Tide", "Lookout", "Grove", "Salon", "Cabana", "Kitchen", "Dusk"]
	var x := 80
	var y := 180
	for i in 12:
		var p := ColorRect.new()
		p.size = Vector2(260, 160)
		p.position = Vector2(x, y)
		p.color = Palette.SAND if i < n else Color(0.75, 0.72, 0.68)
		add_child(p)
		var lab := Label.new()
		lab.text = names[i] if i < n else "—"
		lab.position = Vector2(x + 8, y + 120)
		lab.add_theme_color_override("font_color", Palette.INK)
		add_child(lab)
		x += 300
		if x > 1600:
			x = 80
			y += 200
