extends Control

onready var pips = $"%Planks".get_children()
onready var max_pips = pips.size()
onready var last_valid = max_pips - 1


func has_remaining_pips():
	return last_valid >= 0


func remove_pip():
	var p = pips[last_valid]
	p.modulate = Color.black
	last_valid -= 1


func add_pip():
	var p = pips[last_valid + 1]
	p.modulate = Color.white

