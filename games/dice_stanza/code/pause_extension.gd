extends Control


const Validate = preload("res://games/dice_stanza/code/util/validate.gd")

onready var pop = get_parent()


func _input(_event: InputEvent) -> void:
	if not pop.visible:
		# Don't allow clicking off the popup if there's no time left.
		pop.popup_exclusive = _is_game_over()
		var user_is_panicking = _is_game_over() and Input.is_action_just_pressed("action1")
		if user_is_panicking:
			accept_event()
			pop.call_deferred("popup_without_continue")


func _on_visibility_changed():
	Broadcast_idbrii.block_input(self, visible)


func _is_game_over():
	return Broadcast_idbrii.is_game_over
