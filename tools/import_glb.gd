extends SceneTree


func _init() -> void:
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_file("res://art/models/abandoned_lounge.glb", state)
	print("append ", err)
	if err != OK:
		quit()
		return
	var node := doc.generate_scene(state)
	node.name = "AbandonedLounge"
	var packed := PackedScene.new()
	packed.pack(node)
	var save_err := ResourceSaver.save(packed, "res://art/models/abandoned_lounge.tscn")
	print("save ", save_err, " children ", node.get_child_count())
	quit()
