extends Node



func _input(_event: InputEvent):
	# Toggle fullscreen with Alt-Enter
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen


func transition_to(next_scene: PackedScene):
	assert(next_scene, "Need a scene to transition to.")
	var result = get_tree().change_scene_to(next_scene)
	if result != OK:
		printt("Failed to transition to scene.", result)


func return_to_menu():
	printt("Returning to menu...")
	transition_to(preload("res://mainmenu/mainmenu.tscn"))


