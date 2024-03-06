extends Node2D

func _ready():
	randomize()

func _process(_delta):
	if Input.is_action_just_pressed("action1"):
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(1,1,1,0), 0.5)
		yield(tween, "finished")
		get_tree().change_scene("res://games/Jerimiah/scenes/World.tscn")
