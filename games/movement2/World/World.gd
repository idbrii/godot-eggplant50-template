extends Node2D

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		Eggplant.return_to_menu()
