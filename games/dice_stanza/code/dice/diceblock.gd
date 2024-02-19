extends RigidBody2D

const Validate = preload("res://games/dice_stanza/code/util/validate.gd")

signal picked_up(block, new_owner)
signal dropped(block, old_owner)

export var player_impact_impulse := 300.0

var value
var is_fresh_spawn := true


func _ready():
	Validate.ok(connect("body_entered", self, "_on_body_entered"))

func _on_body_entered(body: Node):
	var is_body_below_us = body.global_position.y > global_position.y
	if body.is_in_group("Player") and is_body_below_us:
		# Bounce the dice to prevent player getting stuck.
		apply_central_impulse(Vector2.UP * player_impact_impulse)


func set_face_value(v):
	value = v
	get_node("%ValueLabel").text = str(v)

func picked_up_by(owner):
	self.add_collision_exception_with(owner)
	self.set_deferred("mode", RigidBody2D.MODE_KINEMATIC)
	emit_signal("picked_up", self, owner)

func dropped_by(owner):
	self.set_mode(RigidBody2D.MODE_RIGID)
	self.remove_collision_exception_with(owner)
	emit_signal("dropped", self, owner)
