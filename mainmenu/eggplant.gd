extends Node

const _main_menu = preload("res://mainmenu/mainmenu.tscn")


func _input(_event: InputEvent):
	# Toggle fullscreen with Alt-Enter
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen


func transition_to(next_scene: PackedScene):
	get_tree().change_scene_to(next_scene)


func return_to_menu():
	transition_to(_main_menu)


