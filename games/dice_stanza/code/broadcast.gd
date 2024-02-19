extends Node

const Validate = preload("res://games/dice_stanza/code/util/validate.gd")
const Tuning = preload("res://games/dice_stanza/code/dice/tuning.gd")


signal player_rolled(value, total_rolls)  # warning-ignore:unused_signal
signal time_expired()
signal set_input_block(should_block)
signal start_round()  # warning-ignore:unused_signal
signal restart_game()  # warning-ignore:unused_signal
signal game_over()  # warning-ignore:unused_signal


var tuning : Dictionary


func _ready():
	Validate.ok(Broadcast_idbrii.connect("start_round", self, "_on_start_round"))
	Validate.ok(Broadcast_idbrii.connect("restart_game", self, "_on_restart_game"))
	Validate.ok(Broadcast_idbrii.connect("game_over", self, "_on_game_over"))


func init_game():
	has_time_remaining = true
	is_game_over = false
	tuning = Tuning.pick_tuning()


func _on_start_round():
	init_game()


func _on_restart_game():
	block_input(self, false)
	init_game()

var is_game_over = false
func _on_game_over():
	is_game_over = true

var has_time_remaining = true
func notify_time_expired():
	has_time_remaining = false
	emit_signal("time_expired")
	block_input(self, true)


var blockers := {}
func block_input(blocker, should_block):
	if should_block:
		if blockers.empty():
			emit_signal("set_input_block", true)
		blockers[blocker] = true
	else:
		Validate.ignore(blockers.erase(blocker))
		if blockers.empty():
			emit_signal("set_input_block", false)
