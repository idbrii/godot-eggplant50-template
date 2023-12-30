extends Node

const _main_menu = preload("res://mainmenu/mainmenu.tscn")

func transition_to(next_scene: PackedScene):
	get_tree().change_scene_to(next_scene)


func return_to_menu():
	transition_to(_main_menu)


