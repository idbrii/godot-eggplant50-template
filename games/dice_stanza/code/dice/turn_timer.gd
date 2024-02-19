extends Node

const DiceBlock = preload("res://games/dice_stanza/scenes/OppoDiceBlock.tscn")
const Random = preload("res://games/dice_stanza/code/util/random.gd")
const Validate = preload("res://games/dice_stanza/code/util/validate.gd")

var game_started = false


func _ready():
	Validate.ok(Broadcast_idbrii.connect("start_round", self, "_on_start_round"))
	Validate.ok(Broadcast_idbrii.connect("player_rolled", self, "_on_player_rolled"))
	Validate.ok($Timer.connect("timeout", self, "_on_game_end"))


func _on_start_round():
	game_started = false
	$Timer.start(Broadcast_idbrii.tuning.time_limit)


func _on_player_rolled(_value, _total_rolls):
	if game_started:
		return
	game_started = true
	$Timer.start(Broadcast_idbrii.tuning.time_limit)


func _process(_dt):
	var progress := 0.0
	if Broadcast_idbrii.has_time_remaining:
		progress = $Timer.time_left / Broadcast_idbrii.tuning.time_limit
	# Always set so we actually see zero value.
	$Visual.set_progress(progress)


func _on_game_end():
	Broadcast_idbrii.notify_time_expired()
