tool
extends AcceptDialog

func show_complaint(msg):
	dialog_text = msg
	get_ok().text = "Cancel"
	self.popup_centered()

