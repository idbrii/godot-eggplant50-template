static func ok(err):
	assert(err == OK)

static func was_true(err):
	assert(err == true)

static func ignore(_err):
	pass

static func _show_error(parent: Node, title: String, msg: String):
	var accept_dialog := AcceptDialog.new()
	accept_dialog.window_title = title
	accept_dialog.dialog_text = msg
	accept_dialog.get_ok().text = "Cancel"
	parent.add_child(accept_dialog)
	accept_dialog.popup_centered()



