extends RigidBody2D

const Validate = preload("res://games/dice_stanza/code/util/validate.gd")

enum Appearance {
	IDLE,
	CARRIED,
	COUNTED,
	OPPO,
}

signal picked_up(block, new_owner)
signal dropped(block, old_owner)

export var player_impact_impulse := 300.0
export(Appearance) var default_appearance := Appearance.IDLE

var value
var is_fresh_spawn := true


func _ready():
	Validate.ok(connect("body_entered", self, "_on_body_entered"))
	set_appearance(default_appearance)

func _on_body_entered(body: Node):
	var is_body_below_us = body.global_position.y > global_position.y
	if body.is_in_group("Player") and is_body_below_us:
		# Bounce the dice to prevent player getting stuck.
		apply_central_impulse(Vector2.UP * player_impact_impulse)


func set_appearance(appearance):
	var sprite = $"%AnimatedSprite"
	match appearance:
		Appearance.IDLE:
			sprite.self_modulate = Color(0x83e04cff)
		Appearance.CARRIED:
			sprite.self_modulate = Color(0xa0e07bff)
		Appearance.COUNTED:
			sprite.self_modulate = Color(0x39855aff)
		#~ Appearance.OPPO:
		#~ 	sprite.self_modulate = Color(0x3898ffff)


func set_face_value(v):
	value = v
	get_node("%ValueLabel").text = str(v)

func picked_up_by(owner):
	self.add_collision_exception_with(owner)
	self.set_deferred("mode", RigidBody2D.MODE_KINEMATIC)
	emit_signal("picked_up", self, owner)
	set_appearance(Appearance.CARRIED)

func dropped_by(owner):
	set_appearance(Appearance.IDLE)
	self.set_mode(RigidBody2D.MODE_RIGID)
	self.remove_collision_exception_with(owner)
	emit_signal("dropped", self, owner)
