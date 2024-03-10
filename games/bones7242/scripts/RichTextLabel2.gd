extends RichTextLabel

func _process(delta):
	var zDistance = get_parent().get_node("baseball_area2d").unprojectedZ
	set_text("Home run distance: 100")
	newline()
	add_text("Your hit distance: " + str(int(zDistance - 4)))
	pass
