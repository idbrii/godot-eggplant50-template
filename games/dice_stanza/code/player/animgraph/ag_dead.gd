extends "res://games/dice_stanza/code/player/animgraph/ag_uber_player.gd"

func enter(data):
	return ._enter_state_dead(data)

func update(dt):
	return ._update_state_generic(dt)

func exit(_data):
	return true

func is_supported():
	return true

