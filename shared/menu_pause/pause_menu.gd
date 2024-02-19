extends Popup

export var supports_restart := true
export var help_title := ""  # Optional
export(String, MULTILINE) var help_body := ""  # If this isn't empty, then we'll show a help button.


static func ok(err):
	assert(err == OK)


# When you hit game over, you can call this to show without the option to
# continue.
func popup_without_continue():
	var continue_btn = get_node("%ContinueButton")
	continue_btn.visible = false
	popup()


func _ready():
	var restart_btn = get_node("%RestartButton")
	var help_btn = get_node("%HelpButton")
	ok(get_node("%ContinueButton").connect("pressed", self, "_on_continue"))
	ok(restart_btn.connect("pressed", self, "_on_restart"))
	ok(help_btn.connect("pressed", self, "_on_help"))
	ok(get_node("%QuitButton").connect("pressed", self, "_on_quit"))
	ok(connect("visibility_changed", self, "_on_visibility_changed"))
	if not supports_restart:
		restart_btn.visible = false
	if not help_body or help_body.length() == 0:
		help_btn.visible = false
	var inputs = $"%InputDisplay"
	inputs.visible = Eggplant.current_game != null
	if inputs.visible:
		inputs.set_game_def(Eggplant.current_game)
	# else: it will look ugly, but not sure how to force the hbox to resize.


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
	Eggplant.restart_scene()


func _on_help():
	$Help.window_title = help_title
	$Help.dialog_text = help_body
	$Help.dialog_autowrap = true
	$Help.popup_centered()


func _set_pause(should_pause):
	# Delay so anything waiting for us to be invisible won't also get the input.
	yield(get_tree(), "idle_frame")
	get_tree().paused = should_pause
