extends Control


const Validate = preload("res://games/dice_stanza/code/util/validate.gd")


func ready():
	visible = false


func start_waiting():
	visible = true
	_set_pause(true)


func _input(_event: InputEvent):
	if visible and (
		Input.is_action_just_pressed("action1")
		or Input.is_action_just_pressed("action2")):
		accept_event()
		yield(_set_pause(false), "completed")
		get_parent().queue_free()


func _set_pause(should_pause):
	printt("Pausing:", should_pause)
	# Delay so anything waiting for us to be invisible won't also get the input.
	yield(get_tree(), "idle_frame")
	get_tree().paused = should_pause
