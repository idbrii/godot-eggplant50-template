extends "res://games/dice_stanza/code/player/sm_uber.gd"

func enter(_data):
	return ._enter_state_freestyle(_data)

func update(_data):
	return ._update_state_freestyle(_data)

func exit(_data):
	return true

func is_supported():
	return ._state_is_supported_by_floor()

