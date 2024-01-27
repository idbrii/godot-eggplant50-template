extends VBoxContainer

signal restart_game()

func _ready() -> void:
	$Restart.connect('pressed', self, 'restart_pressed')
	$Quit.connect('pressed', self, 'quit_pressed')

func _process(_delta):
	if Input.is_action_just_pressed('pause'):
		if visible:
			resume_game()
		else:
			do_pause_stuff()

func do_pause_stuff():
	get_tree().paused = true
	show()

func resume_game():
	get_tree().paused = false
	hide()

func restart_pressed():
	get_tree().paused = false
	Eggplant.restart_scene()

func quit_pressed():
	get_tree().paused = false
	Eggplant.return_to_menu()
