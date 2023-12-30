extends Node2D

const TheList : GameList = preload("res://games/eggplant_games.tres")

onready var ButtonTemplate = get_node("%ButtonTemplate")


func _ready():
	for g in TheList.games:
		var btn = ButtonTemplate.duplicate()
		btn.text = g.game_name
		btn.visible = true
		btn.connect("pressed", self, "_button_pressed", [g])
		ButtonTemplate.get_parent().add_child(btn)


func transition_to(next_scene: PackedScene):
	get_tree().change_scene_to(next_scene)


func _button_pressed(game):
	transition_to(game.initial_scene)
