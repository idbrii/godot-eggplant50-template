extends Node2D

const TheList : GameList = preload("res://games/eggplant_games.tres")

onready var ButtonTemplate = get_node("%ButtonTemplate")
onready var QuitButton = get_node("%Quit")


func _ready():
	QuitButton.connect("pressed", self, "_quit")  # warning-ignore:return_value_discarded
	if OS.get_name().to_lower() in ["web", "html5"]:
		# Quit button doesn't work on web, so hide it. Users have to exit fullscreen instead.
		QuitButton.visible = false

	var needs_focus = true
	for g in TheList.games:
		var btn = add_game(g)
		if needs_focus:
			needs_focus = false
			btn.grab_focus()
		# Uncomment to test scrolling
		#~ for i in range(50):
		#~ 	add_game(g)


func add_game(g) -> Button:
	var btn = ButtonTemplate.duplicate()
	btn.text = "{name} - {author}".format({ "name": g.game_name, "author": g.game_author, })
	btn.visible = true
	btn.connect("pressed", self, "_button_pressed", [g])  # warning-ignore:return_value_discarded
	ButtonTemplate.get_parent().add_child(btn)
	return btn


func _button_pressed(game):
	Eggplant.transition_to(game.initial_scene)


func _quit():
	get_tree().quit()

