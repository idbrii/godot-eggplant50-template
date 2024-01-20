extends Node

const transition_scene = preload("res://mainmenu/scene_transition.tscn")

var last_played_scene : PackedScene


func _ready():
	# To toggle fullscreen while paused.
	pause_mode = PAUSE_MODE_PROCESS


func _input(_event: InputEvent):
	# Toggle fullscreen with Alt-Enter
	if Input.is_action_just_pressed("toggle_fullscreen"):
		get_tree().set_input_as_handled()
		OS.window_fullscreen = !OS.window_fullscreen


func transition_to(next_scene: PackedScene):
	assert(next_scene, "Need a scene to transition to.")
	last_played_scene = next_scene
	var transitioner = transition_scene.instance()
	add_child(transitioner)
	transitioner.fade_transition_to(next_scene)


func restart_scene():
	transition_to(last_played_scene)


func return_to_menu():
	printt("Returning to menu...")
	transition_to(preload("res://mainmenu/mainmenu.tscn"))


