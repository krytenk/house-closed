extends SceneTree

func _init() -> void:
	call_deferred("_go")


func _go() -> void:
	var out: String = OS.get_environment("PALM_SHOT")
	if out == "":
		out = "user://shot.png"
	print("SHOT out=", out)
	var packed: PackedScene = load("res://world/paloma_atoll.tscn")
	if packed == null:
		push_error("no island scene")
		quit(1)
		return
	var inst: Node = packed.instantiate()
	root.add_child(inst)
	await inst.get_tree().create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	var img: Image = root.get_viewport().get_texture().get_image()
	var err: Error = img.save_png(out)
	print("SHOT saved ", err, " ", img.get_width(), "x", img.get_height())
	quit(0)
