extends CanvasLayer

signal restart

func _on_RestartButton_pressed():
	emit_signal("restart")
