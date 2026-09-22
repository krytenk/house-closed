extends RefCounted
class_name CabinetBuilder
## Shared Palm Reels cabinet — same teal pelican face on the floor and in the sit.


const SYM_IDLE := ["P", "C", "H", "S", "L", "W", "B"]


static func mat(color: Color, rough: float = 0.42, emit: Color = Color(0, 0, 0, 0), emit_e: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	if emit_e > 0.0:
		m.emission_enabled = true
		m.emission = emit
		m.emission_energy_multiplier = emit_e
	return m


static func wood_mat(tint: Color, rough: float = 0.55) -> StandardMaterial3D:
	var m := mat(tint, rough)
	var path := "res://art/seasons/paloma/wood.png"
	if ResourceLoader.exists(path):
		m.albedo_texture = load(path)
		m.uv1_scale = Vector3(1.4, 1.4, 1.4)
	return m


static func box(parent: Node, size: Vector3, pos: Vector3, material: Material, name: String = "Box") -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = material
	mi.name = name
	parent.add_child(mi)
	return mi


static func cyl(parent: Node, r: float, h: float, pos: Vector3, material: Material, name: String = "Cyl", rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = r
	mesh.bottom_radius = r
	mesh.height = h
	mesh.radial_segments = 16
	mi.mesh = mesh
	mi.position = pos
	mi.rotation_degrees = rot
	mi.material_override = material
	mi.name = name
	parent.add_child(mi)
	return mi


static func sphere(parent: Node, r: float, pos: Vector3, material: Material, name: String = "Sph") -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = r
	mesh.height = r * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = material
	mi.name = name
	parent.add_child(mi)
	return mi


static func cone(parent: Node, r: float, h: float, pos: Vector3, material: Material, name: String = "Cone", rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.01
	mesh.bottom_radius = r
	mesh.height = h
	mesh.radial_segments = 10
	mi.mesh = mesh
	mi.position = pos
	mi.rotation_degrees = rot
	mi.material_override = material
	mi.name = name
	parent.add_child(mi)
	return mi


## Builds a cabinet facing +Z (toward the player). ReelWindow sits at the glass.
static func build(parent: Node, pos: Vector3 = Vector3.ZERO, scale: float = 1.0, idle_reels: bool = true) -> Node3D:
	var root := Node3D.new()
	root.name = "TikiCabinet"
	root.position = pos
	root.scale = Vector3(scale, scale, scale)
	parent.add_child(root)

	var teal := mat(Color(0.22, 0.64, 0.62), 0.42)
	var bamboo := mat(Color(0.84, 0.64, 0.36), 0.4)
	var dark := mat(Color(0.22, 0.12, 0.07), 0.55)
	var cream := mat(Color(0.92, 0.88, 0.8), 0.45)
	var grey := mat(Color(0.62, 0.58, 0.52), 0.48)
	var beak := mat(Color(0.95, 0.55, 0.16), 0.32)
	var gold := mat(Color(0.95, 0.68, 0.18), 0.38, Color(0.95, 0.55, 0.12), 0.5)
	var leaf := mat(Color(0.32, 0.58, 0.18), 0.45)
	var recess := mat(Color(0.04, 0.04, 0.05), 0.9)

	# Body + plinth
	box(root, Vector3(1.18, 1.55, 0.78), Vector3(0, 0.95, 0), teal, "Body")
	box(root, Vector3(1.32, 0.16, 0.92), Vector3(0, 0.1, 0), dark, "Base")
	cyl(root, 0.055, 0.22, Vector3(-0.48, 0.1, 0.3), bamboo, "LegFL")
	cyl(root, 0.055, 0.22, Vector3(0.48, 0.1, 0.3), bamboo, "LegFR")
	cyl(root, 0.055, 0.22, Vector3(-0.48, 0.1, -0.3), bamboo, "LegBL")
	cyl(root, 0.055, 0.22, Vector3(0.48, 0.1, -0.3), bamboo, "LegBR")

	# Corner bamboo posts
	for x in [-0.56, 0.56]:
		for z in [-0.36, 0.36]:
			cyl(root, 0.045, 1.62, Vector3(x, 0.95, z), bamboo, "Post")

	# Top rail / arched board
	box(root, Vector3(1.22, 0.18, 0.82), Vector3(0, 1.78, 0), teal, "TopRail")
	box(root, Vector3(0.95, 0.28, 0.18), Vector3(0, 2.02, 0.22), teal, "CrestBoard")

	_pelican(root, Vector3(-0.18, 2.18, 0.18), cream, grey, beak)
	_pineapple(root, Vector3(0.38, 2.12, 0.22), gold, leaf)

	# Reel recess + bamboo grid (5x3)
	box(root, Vector3(0.86, 0.7, 0.08), Vector3(0, 1.18, 0.34), recess, "Recess")
	var grid := Node3D.new()
	grid.name = "BambooGrid"
	grid.position = Vector3(0, 1.18, 0.42)
	root.add_child(grid)
	# Outer frame
	box(grid, Vector3(0.9, 0.06, 0.07), Vector3(0, 0.38, 0), bamboo, "FrameTop")
	box(grid, Vector3(0.9, 0.06, 0.07), Vector3(0, -0.38, 0), bamboo, "FrameBot")
	box(grid, Vector3(0.06, 0.76, 0.07), Vector3(-0.42, 0, 0), bamboo, "FrameL")
	box(grid, Vector3(0.06, 0.76, 0.07), Vector3(0.42, 0, 0), bamboo, "FrameR")
	# 4 inner verts (5 columns), 2 inner horiz (3 rows)
	for i in 4:
		var vx: float = -0.252 + float(i) * 0.168
		cyl(grid, 0.011, 0.72, Vector3(vx, 0, 0.01), bamboo, "VBar")
	for i in 2:
		var hy: float = 0.13 - float(i) * 0.26
		cyl(grid, 0.01, 0.84, Vector3(0, hy, 0.01), bamboo, "HBar", Vector3(0, 0, 90))

	# Glass
	var glass := MeshInstance3D.new()
	var gquad := QuadMesh.new()
	gquad.size = Vector2(0.8, 0.64)
	glass.mesh = gquad
	glass.position = Vector3(0, 1.18, 0.445)
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color(0.7, 0.85, 0.9, 0.05)
	gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gm.roughness = 0.08
	gm.metallic = 0.15
	glass.material_override = gm
	glass.name = "Glass"
	root.add_child(glass)

	# Boat tray + belly
	box(root, Vector3(0.82, 0.38, 0.1), Vector3(0, 0.5, 0.4), teal, "Belly")
	box(root, Vector3(0.7, 0.05, 0.24), Vector3(0, 0.48, 0.54), teal, "TrayFloor")
	box(root, Vector3(0.06, 0.12, 0.24), Vector3(-0.32, 0.54, 0.54), teal, "TrayL")
	box(root, Vector3(0.06, 0.12, 0.24), Vector3(0.32, 0.54, 0.54), teal, "TrayR")
	box(root, Vector3(0.7, 0.12, 0.05), Vector3(0, 0.54, 0.42), teal, "TrayBack")
	box(root, Vector3(0.48, 0.06, 0.12), Vector3(0, 0.36, 0.5), dark, "Buttons")

	# Side rope / starfish marks
	cyl(root, 0.012, 0.9, Vector3(0.6, 0.95, 0.2), bamboo, "Rope", Vector3(12, 0, 8))
	sphere(root, 0.05, Vector3(0.58, 0.55, 0.4), gold, "Star")

	var rw := Node3D.new()
	rw.name = "ReelWindow"
	rw.position = Vector3(0, 1.18, 0.40)
	root.add_child(rw)
	var window_light := OmniLight3D.new()
	window_light.name = "WindowLight"
	window_light.light_color = Color(1.0, 0.82, 0.5)
	window_light.light_energy = 0.9
	window_light.omni_range = 2.0
	window_light.position = Vector3(0, 1.18, 0.85)
	root.add_child(window_light)

	var body := StaticBody3D.new()
	body.name = "BodyCol"
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.25, 2.2, 0.95)
	col.shape = shape
	col.position = Vector3(0, 1.1, 0)
	body.add_child(col)
	root.add_child(body)

	if idle_reels:
		fill_idle_reels(rw)
	return root


static func fill_idle_reels(anchor: Node3D) -> void:
	if anchor == null:
		return
	for child in anchor.get_children():
		if str(child.name).begins_with("Cell_"):
			child.queue_free()
	for col in 5:
		for row in 3:
			var mi := MeshInstance3D.new()
			var quad := QuadMesh.new()
			quad.size = Vector2(0.13, 0.16)
			mi.mesh = quad
			mi.position = Vector3(-0.26 + float(col) * 0.13, 0.16 - float(row) * 0.16, 0.0)
			var m := StandardMaterial3D.new()
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			m.albedo_texture = _sym_tex(SYM_IDLE[(col * 3 + row) % SYM_IDLE.size()])
			m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
			mi.material_override = m
			mi.name = "Cell_%d_%d" % [col, row]
			anchor.add_child(mi)


static func _sym_tex(sym: String) -> Texture2D:
	var path := "res://art/seasons/paloma/sym_%s.png" % sym
	if ResourceLoader.exists(path):
		return load(path)
	return load("res://art/seasons/paloma/sym_L.png")


static func _pelican(root: Node, pos: Vector3, cream: Material, grey: Material, beak_m: Material) -> void:
	var p := Node3D.new()
	p.name = "Pelican"
	p.position = pos
	root.add_child(p)
	sphere(p, 0.15, Vector3(0, 0.04, 0), cream, "Body")
	sphere(p, 0.1, Vector3(0.02, 0.16, 0.08), cream, "Head")
	box(p, Vector3(0.34, 0.055, 0.055), Vector3(0.22, 0.14, 0.18), beak_m, "Beak")
	sphere(p, 0.028, Vector3(0.38, 0.14, 0.2), beak_m, "BeakTip")
	sphere(p, 0.018, Vector3(0.06, 0.2, 0.16), mat(Color(0.08, 0.08, 0.08)), "Eye")
	box(p, Vector3(0.24, 0.06, 0.18), Vector3(-0.1, 0.04, 0.0), grey, "Wing")
	cyl(p, 0.022, 0.1, Vector3(-0.04, -0.14, 0.04), beak_m, "LegL")
	cyl(p, 0.022, 0.1, Vector3(0.06, -0.14, 0.04), beak_m, "LegR")


## Large loose statue. Pivot through the chest. Meant to be grabbed and turned.
static func build_statue_bird(parent: Node, pos: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = "LooseBird"
	root.position = pos
	parent.add_child(root)
	var cream := mat(Color(0.96, 0.91, 0.78), 0.48)
	var grey := mat(Color(0.62, 0.52, 0.38), 0.55)
	var beak := mat(Color(0.92, 0.55, 0.16), 0.35)
	var brass := mat(Color(0.72, 0.52, 0.18), 0.32)
	var dark := mat(Color(0.12, 0.08, 0.05), 0.55)
	cyl(root, 0.04, 0.55, Vector3(0, 0.12, 0), brass, "Pivot")
	box(root, Vector3(0.22, 0.06, 0.22), Vector3(0, -0.14, 0), dark, "BasePlate")
	var body := Node3D.new()
	body.name = "Spin"
	root.add_child(body)
	sphere(body, 0.28, Vector3(0, 0.22, 0.02), cream, "Chest")
	sphere(body, 0.18, Vector3(0.04, 0.48, 0.14), cream, "Head")
	box(body, Vector3(0.55, 0.1, 0.1), Vector3(0.38, 0.44, 0.28), beak, "Beak")
	sphere(body, 0.05, Vector3(0.64, 0.44, 0.32), beak, "BeakTip")
	sphere(body, 0.035, Vector3(0.12, 0.54, 0.28), mat(Color(0.06, 0.06, 0.06)), "Eye")
	box(body, Vector3(0.42, 0.1, 0.32), Vector3(-0.18, 0.22, 0.0), grey, "Wing")
	box(body, Vector3(0.12, 0.22, 0.08), Vector3(0.02, 0.62, 0.08), cream, "Crest")
	cyl(body, 0.04, 0.18, Vector3(-0.06, -0.02, 0.08), beak, "LegL")
	cyl(body, 0.04, 0.18, Vector3(0.1, -0.02, 0.08), beak, "LegR")
	return root


static func _pineapple(root: Node, pos: Vector3, gold: Material, leaf: Material) -> void:
	var n := Node3D.new()
	n.name = "Pineapple"
	n.position = pos
	root.add_child(n)
	sphere(n, 0.13, Vector3(0, 0.02, 0), gold, "Fruit")
	box(n, Vector3(0.18, 0.04, 0.18), Vector3(0, 0.02, 0), mat(Color(0.75, 0.45, 0.12), 0.5), "Band")
	for i in 5:
		var a: float = deg_to_rad(-40.0 + float(i) * 20.0)
		cone(n, 0.04, 0.16, Vector3(sin(a) * 0.03, 0.16, cos(a) * 0.02), leaf, "Leaf", Vector3(12, 0, rad_to_deg(a)))
