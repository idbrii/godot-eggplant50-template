extends Node

const DiceBlock = preload("res://games/dice_stanza/scenes/PlayerDiceBlock.tscn")
const Random = preload("res://games/dice_stanza/code/util/random.gd")
const Validate = preload("res://games/dice_stanza/code/util/validate.gd")


onready var drop_spot = $DropSpot

var past_blocks = []

func _ready():
	Validate.ok(Broadcast_idbrii.connect("start_round", self, "_on_start_round"))


func _on_start_round():
	for b in past_blocks:
		b.queue_free()
	past_blocks.clear()
	# Delay a frame for everyone else to register to player_rolled.
	yield(get_tree(), "idle_frame")
	roll()


func roll():
	var block = DiceBlock.instance()
	past_blocks.append(block)
	var v = Random.integer(1, 6)
	block.set_face_value(v)
	Validate.ok(block.connect("picked_up", self, "_on_block_picked_up"))

	drop_spot.add_child(block)
	block.position = Vector2.ZERO
	block.set_mode(RigidBody2D.MODE_RIGID)
	Broadcast_idbrii.emit_signal("player_rolled", v, past_blocks.size())


func _on_block_picked_up(block, _owner):
	if (Broadcast_idbrii.has_time_remaining
		and block.is_fresh_spawn
		and past_blocks.size() < Broadcast_idbrii.tuning.player_rolls
		):
		block.is_fresh_spawn = false
		call_deferred("roll")
