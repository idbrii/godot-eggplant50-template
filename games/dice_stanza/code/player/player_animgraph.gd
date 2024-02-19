extends Node

const Validate = preload("res://games/dice_stanza/code/util/validate.gd")
const Vec = preload("res://games/dice_stanza/code/util/vec.gd")
const StateMachine = preload("res://games/dice_stanza/code/common/statemachine.gd")


export var player_path : NodePath
onready var player := get_node(player_path)
onready var _scale_animator := $AnimationPlayer
onready var _sprite_animator := $AnimatedSprite2D

onready var states = {
	default_state = $StateMachine/Default,
	ground_idle = $StateMachine/Ground_idle,
	ground_run = $StateMachine/Ground_run,
	climb = $StateMachine/Climb,
	jump = $StateMachine/Jump,
	fall = $StateMachine/Fall,
	land = $StateMachine/Land,
	dash = $StateMachine/Dash,
}

onready var sounds = {
	jump = $"../Sound/Jump",
	pickup = $"../Sound/Pickup",
	hit = $"../Sound/Hit",
}

static func create_statemachine(parent : Node, all_states) -> StateMachine:
	var machine = StateMachine.new()
	machine.create_states(all_states)
	parent.add_child(machine)
	return machine


onready var sm : StateMachine = create_statemachine(self, states)


func _ready() -> void:
	assert(_scale_animator, "Need AnimationPlayer")
	assert(_sprite_animator, "Need AnimatedSprite2D")

	for key in states:
		var item = states[key]
		item.sm = sm
		item.ag = self

	if player == null:
		# Avoid errors
		print("player_animgraph.gd is missing player_path")
		set_process(false)
	else:
		Validate.ok(player.connect("facing_flipped", self, "_on_facing_flipped"))
		#~ sm.add_label($ui_root/label_bookmark)
		sm.transition_to(states.ground_idle, {})


func _on_facing_flipped(should_face_right):
	_sprite_animator.flip_h = should_face_right


func _process(dt: float) -> void:
	sm.tick(dt)
