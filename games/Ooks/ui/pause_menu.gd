extends Popup



static func ok(err):
	assert(err == OK)


func _ready():
	ok(get_node("%ContinueButton").connect("pressed", self, "_on_continue"))
	ok(get_node("%RestartButton").connect("pressed", self, "_on_restart"))
	ok(get_node("%QuitButton").connect("pressed", self, "_on_quit"))
	ok(connect("visibility_changed", self, "_on_visibility_changed"))


func _input(_event: InputEvent) -> void:
	if not visible and Input.is_action_just_pressed("pause"):
		accept_event()
		call_deferred("popup")


func _on_visibility_changed():
	_set_pause(visible)


func _on_continue():
	_set_pause(false)
	visible = false


func _on_quit():
	_set_pause(false)
	Eggplant.return_to_menu()


func _on_restart():
	_set_pause(false)
	var ThisGameDef = load("res://games/Ooks/ooks.tres")
	Eggplant.transition_to(ThisGameDef.initial_scene)


func _set_pause(should_pause):
	# Delay so anything waiting for us to be invisible won't also get the input.
	yield(get_tree(), "idle_frame")
	get_tree().paused = should_pause
