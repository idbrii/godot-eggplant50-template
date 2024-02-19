extends Popup

export var supports_restart := true

const Validate = preload("res://games/dice_stanza/code/util/validate.gd")



func _ready():
	var restart_btn = get_node("%RestartButton")
	Validate.ok(get_node("%ContinueButton").connect("pressed", self, "_on_continue"))
	Validate.ok(restart_btn.connect("pressed", self, "_on_restart"))
	Validate.ok(get_node("%QuitButton").connect("pressed", self, "_on_quit"))
	Validate.ok(connect("visibility_changed", self, "_on_visibility_changed"))
	if not supports_restart:
		restart_btn.visible = false


func _input(_event: InputEvent) -> void:
	if not visible:
		# Don't allow clicking off the popup if there's no time left.
		popup_exclusive = _is_game_over()
		var user_is_panicking = _is_game_over() and Input.is_action_just_pressed("action1")
		if Input.is_action_just_pressed("pause") or user_is_panicking:
			accept_event()
			call_deferred("popup")


func _on_visibility_changed():
	_set_pause(visible)
	Broadcast_idbrii.block_input(self, visible)


func _is_game_over():
	return Broadcast_idbrii.is_game_over


func _on_continue():
	_set_pause(false)
	visible = false


func _on_quit():
	_set_pause(false)
	Eggplant.return_to_menu()


func _on_restart():
	_set_pause(false)
	Broadcast_idbrii.emit_signal("restart_game")
	Eggplant.restart_scene()


func _set_pause(should_pause):
	# Delay so anything waiting for us to be invisible won't also get the input.
	yield(get_tree(), "idle_frame")
	get_tree().paused = should_pause
