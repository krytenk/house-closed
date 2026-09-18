extends Object
class_name IslandKit
## Chunky toy-diorama meshes. No photo billboards.


static func mat(color: Color, rough: float = 0.62, tex: Texture2D = null) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	m.metallic = 0.0
	if tex:
		m.albedo_texture = tex
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	return m


static func inst(parent: Node, mesh: Mesh, pos: Vector3, material: Material, rot := Vector3.ZERO) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.mesh = mesh
	n.position = pos
	n.rotation_degrees = rot
	n.material_override = material
	parent.add_child(n)
	return n


static func box(parent: Node, size: Vector3, pos: Vector3, color: Color, rot := Vector3.ZERO) -> MeshInstance3D:
	var m := BoxMesh.new()
	m.size = size
	return inst(parent, m, pos, mat(color), rot)


static func cyl(parent: Node, r_top: float, r_bot: float, h: float, pos: Vector3, color: Color, segs: int = 12, rot := Vector3.ZERO) -> MeshInstance3D:
	var m := CylinderMesh.new()
	m.top_radius = r_top
	m.bottom_radius = r_bot
	m.height = h
	m.radial_segments = segs
	return inst(parent, m, pos, mat(color), rot)


static func sphere(parent: Node, r: float, pos: Vector3, color: Color) -> MeshInstance3D:
	var m := SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	return inst(parent, m, pos, mat(color))


static func torus(parent: Node, inner: float, outer: float, pos: Vector3, color: Color, rot := Vector3.ZERO) -> MeshInstance3D:
	var m := TorusMesh.new()
	m.inner_radius = inner
	m.outer_radius = outer
	m.rings = 24
	m.ring_segments = 12
	return inst(parent, m, pos, mat(color), rot)


static func add_palm(parent: Node, pos: Vector3, scale := 1.0) -> void:
	cyl(parent, 0.07 * scale, 0.12 * scale, 2.4 * scale, pos + Vector3(0.08 * scale, 1.2 * scale, 0), Color("#6B4F2A"), 8, Vector3(0, 0, 6))
	var green := Color("#3FA34D")
	for i in 6:
		var ang: float = float(i) / 6.0 * TAU
		var fr := SphereMesh.new()
		fr.radius = 0.42 * scale
		fr.height = 0.55 * scale
		inst(parent, fr, pos + Vector3(cos(ang) * 0.45 * scale, 2.45 * scale, sin(ang) * 0.45 * scale), mat(green))
	sphere(parent, 0.28 * scale, pos + Vector3(0, 2.5 * scale, 0), Color("#2E8B57"))


static func add_bungalow(parent: Node, pos: Vector3, yaw: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = yaw
	parent.add_child(root)
	var wood := Color("#C4A35A")
	var cream := Color("#F7F1E3")
	var thatch := Color("#C9A15B")
	var teal := Color("#2EC4B6")
	for x in [-0.7, 0.7]:
		for z in [-0.7, 0.7]:
			cyl(root, 0.07, 0.09, 1.6, Vector3(x, 0.4, z), wood, 6)
	box(root, Vector3(2.2, 0.12, 2.2), Vector3(0, 1.22, 0), wood)
	box(root, Vector3(1.7, 1.1, 1.7), Vector3(0, 1.82, 0), cream)
	box(root, Vector3(0.35, 0.45, 0.08), Vector3(0.55, 1.75, 0.86), teal)
	box(root, Vector3(0.35, 0.45, 0.08), Vector3(-0.55, 1.75, 0.86), teal)
	cyl(root, 0.04, 1.35, 0.85, Vector3(0, 2.7, 0), thatch, 8)
	box(root, Vector3(0.9, 0.7, 0.08), Vector3(0, 1.7, -0.88), Color("#E8A0B0"))


static func add_pavilion(parent: Node, pos: Vector3, yaw: float, accent: Color) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = yaw
	parent.add_child(root)
	var wood := Color("#C4A35A")
	for x in [-1.4, 1.4]:
		for z in [-1.4, 1.4]:
			cyl(root, 0.09, 0.11, 2.2, Vector3(x, 0.7, z), wood, 8)
	box(root, Vector3(3.2, 0.12, 3.2), Vector3(0, 1.85, 0), wood)
	cyl(root, 0.05, 2.1, 1.0, Vector3(0, 2.5, 0), Color("#C9A15B"), 10)
	box(root, Vector3(1.8, 0.08, 1.8), Vector3(0, 1.22, 0), accent)


static func add_boat(parent: Node, pos: Vector3, yaw: float, hull: Color) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = yaw
	parent.add_child(root)
	box(root, Vector3(1.8, 0.35, 0.7), Vector3(0, 0.2, 0), hull)
	box(root, Vector3(0.7, 0.4, 0.55), Vector3(-0.2, 0.5, 0), Color("#F7F1E3"))
	cyl(root, 0.04, 0.04, 0.5, Vector3(0.55, 0.55, 0), Color("#1B1B1B"), 6, Vector3(0, 0, 90))


static func add_pelican(parent: Node, pos: Vector3) -> void:
	var root := Node3D.new()
	root.position = pos
	root.name = "Shades"
	parent.add_child(root)
	cyl(root, 0.16, 0.2, 1.15, Vector3(0, 0.4, 0), Color("#C4A35A"), 8)
	sphere(root, 0.32, Vector3(0, 1.15, 0), Color("#F7F1E3"))
	sphere(root, 0.22, Vector3(0.12, 1.42, 0.12), Color("#F7F1E3"))
	var beak := BoxMesh.new()
	beak.size = Vector3(0.55, 0.1, 0.12)
	inst(root, beak, Vector3(0.42, 1.38, 0.22), mat(Color("#F4A261")))
	# sunglasses — two discs + bridge, not a photo
	cyl(root, 0.09, 0.09, 0.04, Vector3(0.22, 1.48, 0.28), Color("#1B1B1B"), 10, Vector3(80, 20, 0))
	cyl(root, 0.09, 0.09, 0.04, Vector3(0.08, 1.5, 0.32), Color("#1B1B1B"), 10, Vector3(80, 20, 0))
	box(root, Vector3(0.12, 0.03, 0.03), Vector3(0.15, 1.5, 0.3), Color("#1B1B1B"))
	cyl(root, 0.035, 0.04, 0.35, Vector3(-0.1, 0.95, 0.08), Color("#F4A261"), 6)
	cyl(root, 0.035, 0.04, 0.35, Vector3(0.1, 0.95, -0.05), Color("#F4A261"), 6)


static func add_adult_token(parent: Node, pos: Vector3, shirt: Color) -> MeshInstance3D:
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)
	cyl(root, 0.13, 0.16, 0.55, Vector3(0, 0.45, 0), shirt, 8)
	sphere(root, 0.14, Vector3(0, 0.86, 0), Color("#E2C290"))
	box(root, Vector3(0.28, 0.08, 0.28), Vector3(0, 1.0, 0), Color("#F7F1E3"))
	return cyl(root, 0.05, 0.05, 0.2, Vector3(0, 0.12, 0), Color("#C4A35A"), 6)


static func add_tiki_cabinet(parent: Node, pos: Vector3, yaw: float) -> Node3D:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = yaw
	root.name = "TikiCabinet"
	parent.add_child(root)
	var wood := Color("#6B3F24")
	var dark := Color("#3A2416")
	box(root, Vector3(1.15, 1.7, 0.7), Vector3(0, 0.85, 0), wood)
	# tiki head
	cyl(root, 0.42, 0.48, 0.7, Vector3(0, 1.95, 0), wood, 8)
	box(root, Vector3(0.7, 0.12, 0.2), Vector3(0, 2.15, 0.35), dark)
	sphere(root, 0.08, Vector3(-0.12, 2.05, 0.38), Color("#F4A261"))
	sphere(root, 0.08, Vector3(0.12, 2.05, 0.38), Color("#F4A261"))
	box(root, Vector3(0.35, 0.08, 0.12), Vector3(0, 1.82, 0.38), dark)
	# reel window — real 3D glass, symbols go here
	var glass := box(root, Vector3(0.85, 0.72, 0.06), Vector3(0, 1.05, 0.38), Color(0.05, 0.04, 0.03, 1))
	glass.name = "ReelWindow"
	box(root, Vector3(0.5, 0.12, 0.12), Vector3(0, 0.28, 0.4), Color("#1B1B1B"))
	return root


static func add_tide_machine(parent: Node, pos: Vector3) -> Node3D:
	var root := Node3D.new()
	root.position = pos
	root.name = "TideMachine"
	parent.add_child(root)
	var bamboo := Color("#C4A35A")
	var pink := Color("#E07A9A")
	var teal := Color("#2EC4B6")
	var yellow := Color("#E8C547")
	var purple := Color("#7B6BB0")
	var coral := Color("#E07A5F")
	# platform / splash
	box(root, Vector3(2.4, 0.22, 2.4), Vector3(0.2, 0.12, -0.4), Color("#3D7CA8"))
	box(root, Vector3(1.6, 0.08, 1.2), Vector3(0.3, 0.28, -1.1), Color("#2A6A9A"))
	# tower posts
	for x in [-0.9, 0.9]:
		cyl(root, 0.1, 0.12, 4.6, Vector3(x, 2.4, 0.2), bamboo, 8)
	cyl(root, 0.1, 0.12, 3.4, Vector3(0, 1.8, 0.9), bamboo, 8)
	# ship's wheel
	torus(root, 0.55, 0.72, Vector3(-0.2, 4.4, 0.1), pink, Vector3(90, 0, 20))
	for i in 8:
		var a: float = float(i) / 8.0 * TAU
		box(root, Vector3(1.1, 0.07, 0.07), Vector3(-0.2 + cos(a) * 0.05, 4.4, 0.1), teal, Vector3(0, rad_to_deg(a), 0))
	# gears
	cyl(root, 0.45, 0.45, 0.18, Vector3(0.15, 3.6, 0.35), Color("#D4A017"), 12, Vector3(90, 0, 0))
	cyl(root, 0.28, 0.28, 0.16, Vector3(0.55, 3.25, 0.4), Color("#C4A35A"), 10, Vector3(90, 0, 0))
	# pipes
	cyl(root, 0.12, 0.12, 1.4, Vector3(0.9, 3.9, -0.2), purple, 8, Vector3(0, 0, 55))
	cyl(root, 0.12, 0.12, 1.1, Vector3(1.3, 3.2, -0.6), yellow, 8, Vector3(0, 0, 100))
	# bucket
	cyl(root, 0.28, 0.22, 0.4, Vector3(1.15, 2.55, -0.5), teal, 10)
	# flip-flop
	box(root, Vector3(0.7, 0.08, 0.35), Vector3(1.35, 2.15, -0.9), pink, Vector3(0, 25, 18))
	box(root, Vector3(0.18, 0.06, 0.08), Vector3(1.5, 2.22, -0.9), Color("#F7F1E3"))
	# coconut on gutter
	box(root, Vector3(1.6, 0.08, 0.45), Vector3(-0.2, 2.0, -0.2), Color("#A8B0B8"), Vector3(0, 0, -18))
	sphere(root, 0.22, Vector3(-0.6, 2.25, -0.15), Color("#6B4F2A"))
	# crab
	sphere(root, 0.2, Vector3(-1.15, 1.55, 0.35), coral)
	sphere(root, 0.08, Vector3(-1.35, 1.62, 0.5), coral)
	sphere(root, 0.08, Vector3(-1.0, 1.62, 0.55), coral)
	# diving board
	box(root, Vector3(1.3, 0.1, 0.4), Vector3(0.4, 1.55, -0.85), yellow)
	box(root, Vector3(1.1, 0.12, 1.1), Vector3(0.5, 1.35, -0.85), Color("#7EC8E3"))
	box(root, Vector3(1.1, 0.12, 1.1), Vector3(0.5, 1.15, -0.85), Color("#E8C547"))
	# umbrella cage
	cyl(root, 0.55, 0.55, 0.7, Vector3(0.2, 0.7, -1.15), Color("#C4A35A"), 10)
	cyl(root, 0.62, 0.08, 0.12, Vector3(0.2, 1.05, -1.15), Color("#E07A5F"), 10)
	# spring toy
	cyl(root, 0.12, 0.12, 0.7, Vector3(-1.35, 1.0, 0.9), yellow, 8)
	sphere(root, 0.18, Vector3(-1.35, 1.45, 0.9), coral)
	return root
