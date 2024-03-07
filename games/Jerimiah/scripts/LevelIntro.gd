extends Node2D

func _ready():
	randomize()
	$Tween.interpolate_property($Paper, 'position:y', $Paper.position.y, $Paper.position.y + 10, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	yield(get_tree().create_timer(5.0, false), 'timeout')
	$Tween.start()


func _process(_delta):
	if Input.is_action_just_pressed("action1"):
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(1,1,1,0), 0.5)
		yield(tween, "finished")
		get_tree().change_scene("res://games/Jerimiah/scenes/World.tscn")
