extends Control


const Validate = preload("res://games/dice_stanza/code/util/validate.gd")


func ready():
	visible = false
	pause_mode = PAUSE_MODE_PROCESS


func start_waiting():
	visible = true
	while visible:
		# For some reason using idle_frame breaks dice_stanza, so use timer.
		yield(get_tree().create_timer(0.1), "timeout")


func _input(_event: InputEvent):
	if visible and (
		Input.is_action_just_pressed("action1")
		or Input.is_action_just_pressed("action2")):
		accept_event()
		yield(get_tree(), "idle_frame")
		visible = false
