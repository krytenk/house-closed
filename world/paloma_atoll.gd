extends Node3D

const TILE_COLORS := [
	Color("#C4A35A"), Color("#E2C290"), Color("#2EC4B6"), Color("#C4A35A"),
	Color("#0B6E6F"), Color("#E07A5F"), Color("#E2C290"), Color("#1B1B1B"),
	Color("#C4A35A"), Color("#F4A261"), Color("#C4A35A"), Color("#1B1B1B"),
	Color("#C4A35A"), Color("#2EC4B6"), Color("#C4A35A"), Color("#1B1B1B"),
	Color("#E2C290"), Color("#E07A5F"), Color("#C4A35A"), Color("#F4A261"),
	Color("#F4A261"), Color("#C4A35A"), Color("#E2C290"), Color("#C4A35A"),
]


func _ready() -> void:
	_build()
	$Board.token_tile = int(Save.progress.get("token_tile", 0))
	_place_token()
	Game._set_hud_visible(true)
	$Enter.pressed.connect(_on_enter)
	$Enter.custom_minimum_size = Vector2(200, 52)
	_update_enter()


func _process(_delta: float) -> void:
	_place_token()
	_update_enter()
	if Input.is_action_just_pressed("walk"):
		$Board.walk()
	if Input.is_action_just_pressed("ui_cancel"):
		Game.goto("pause")


func _build() -> void:
	var water := CSGCylinder3D.new()
	water.radius = 7.2
	water.height = 0.4
	water.position = Vector3(0, -0.2, 0)
	var water_mat := StandardMaterial3D.new()
	water_mat.albedo_color = Palette.DEEP
	water.material = water_mat
	add_child(water)
	var lagoon := CSGCylinder3D.new()
	lagoon.radius = 6.4
	lagoon.height = 0.35
	lagoon.position = Vector3(0, -0.12, 0)
	var lagoon_mat := StandardMaterial3D.new()
	lagoon_mat.albedo_color = Palette.LAGOON
	lagoon.material = lagoon_mat
	add_child(lagoon)
	var sand := CSGCylinder3D.new()
	sand.radius = 8.6
	sand.height = 0.25
	sand.position = Vector3(0, -0.35, 0)
	var sand_mat := StandardMaterial3D.new()
	sand_mat.albedo_color = Palette.SAND
	sand.material = sand_mat
	add_child(sand)
	for i in 24:
		var ang: float = float(i) / 24.0 * TAU
		var x: float = cos(ang) * 9.4
		var z: float = sin(ang) * 9.4
		var box := CSGBox3D.new()
		box.size = Vector3(1.6, 0.28, 1.6)
		box.position = Vector3(x, 0.05, z)
		box.rotation.y = -ang
		var mat := StandardMaterial3D.new()
		mat.albedo_color = TILE_COLORS[i]
		box.material = mat
		box.name = "Tile_%02d" % i
		add_child(box)
		var lab := Label3D.new()
		lab.text = str($Board.tile_at(i).get("id", i))
		lab.font_size = 48
		lab.position = Vector3(x, 0.4, z)
		lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		lab.modulate = Palette.INK
		add_child(lab)
	var machine := CSGBox3D.new()
	machine.size = Vector3(2.4, 2.8, 2.4)
	machine.position = Vector3(0, 1.2, 0)
	var bamboo := StandardMaterial3D.new()
	bamboo.albedo_color = Palette.BAMBOO
	machine.material = bamboo
	machine.name = "TidePlaza"
	add_child(machine)
	var tok_mat := StandardMaterial3D.new()
	tok_mat.albedo_color = Palette.CORAL
	$Token.material = tok_mat
	for i in 4:
		var hut := CSGBox3D.new()
		var ang: float = 0.6 + float(i) * 0.9
		hut.size = Vector3(1.1, 0.9, 1.1)
		hut.position = Vector3(cos(ang) * 4.2, 0.5, sin(ang) * 4.2)
		var cream := StandardMaterial3D.new()
		cream.albedo_color = Palette.CREAM
		hut.material = cream
		add_child(hut)
		var roof := CSGCylinder3D.new()
		roof.radius = 0.85
		roof.height = 0.55
		roof.cone = true
		roof.position = hut.position + Vector3(0, 0.7, 0)
		var thatch := StandardMaterial3D.new()
		thatch.albedo_color = Palette.BAMBOO
		roof.material = thatch
		add_child(roof)
	var pelican := CSGSphere3D.new()
	pelican.radius = 0.22
	pelican.position = Vector3(3.2, 0.7, 2.1)
	var pel_mat := StandardMaterial3D.new()
	pel_mat.albedo_color = Palette.CREAM
	pelican.material = pel_mat
	pelican.name = "Shades"
	add_child(pelican)
	var glasses := CSGBox3D.new()
	glasses.size = Vector3(0.28, 0.08, 0.08)
	glasses.position = pelican.position + Vector3(0.12, 0.05, 0.12)
	var ink := StandardMaterial3D.new()
	ink.albedo_color = Palette.INK
	glasses.material = ink
	add_child(glasses)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 40, 0)
	sun.light_color = Color(1.0, 0.86, 0.62)
	sun.light_energy = 1.15
	add_child(sun)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Palette.DEEP
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(1.0, 0.84, 0.62)
	e.ambient_light_energy = 0.55
	env.environment = e
	add_child(env)


func _place_token() -> void:
	var i: int = $Board.token_tile
	var ang: float = float(i) / 24.0 * TAU
	$Token.position = Vector3(cos(ang) * 9.4, 0.55, sin(ang) * 9.4)


func _on_enter() -> void:
	$Board.tap_current()


func _update_enter() -> void:
	var tile: Dictionary = $Board.tile_at($Board.token_tile)
	var tap: String = str(tile.get("tap", ""))
	$Enter.visible = tap != ""
	if tap != "":
		var label: String = str(tile.get("label", tap)).to_upper()
		$Enter.text = label if label != "" else Game.text("enter")
