extends Node2D

const Validate = preload("res://games/dice_stanza/code/util/validate.gd")

export(Array, Resource) var level_list


func _ready():
	var template = $"%ButtonTemplate"
	var i = 0
	for item in level_list:
		i += 1
		var btn = template.duplicate()
		btn.text = "Level {num}".format({num = i})
		btn.visible = true
		template.get_parent().add_child(btn)
		Validate.ok(btn.connect("pressed", self, "_on_levelselect", [item]))
		if i == 1:
			btn.grab_focus()

	var quit_btn = $"%Quit"
	Validate.ok(quit_btn.connect("pressed", self, "_on_quit"))


func _on_quit():
	Eggplant.return_to_menu()


func _on_levelselect(level):
	# Delay so anything waiting for us to be invisible won't also get the input.
	yield(get_tree(), "idle_frame")
	Eggplant.transition_to(level)
