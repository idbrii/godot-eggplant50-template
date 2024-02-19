extends Popup

export var supports_restart := true

static func ok(err):
	assert(err == OK)


func _ready():
	var restart_btn = get_node("%RestartButton")
	ok(restart_btn.connect("pressed", self, "_on_restart"))
	ok(get_node("%QuitButton").connect("pressed", self, "_on_quit"))
	ok(connect("visibility_changed", self, "_on_visibility_changed"))
	if not supports_restart:
		restart_btn.visible = false


func _on_game_over():
	call_deferred("popup")

func _on_visibility_changed():
	_set_pause(visible)


func _on_quit():
	_set_pause(false)
	Eggplant.return_to_menu()


func _on_restart():
	_set_pause(false)
	Eggplant.restart_scene()


func _set_pause(should_pause):
	# Delay so anything waiting for us to be invisible won't also get the input.
	yield(get_tree(), "idle_frame")
	get_tree().paused = should_pause
