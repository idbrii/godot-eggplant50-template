extends KinematicBody2D
##From TheoTheTorch:
# This character controller was created with the intent of being a decent starting point for Platformers.
#
# Instead of teaching the basics, I tried to implement more advanced considerations.
# That's why I call it 'Movement 2'. This is a sequel to learning demos of similar a kind.
# Beyond coyote time and a jump buffer I go through all the things listed in the following video:
# https://www.youtube.com/watch?v=2S3g8CgBG1g
# Except for separate air and ground acceleration, as I don't think it's necessary.


const Validate = preload("res://games/dice_stanza/code/util/validate.gd")
const StateMachine = preload("res://games/dice_stanza/code/common/statemachine.gd")


signal facing_flipped(should_face_right)

export(float, 50, 1000, 1) var throw_forward_strength := 100.0
export(float, 50, 1000, 1) var throw_up_strength := 100.0
export(float, 50, 1000, 1) var push_strength := 50.0

# Freestyle Ground and jump movement {{{1

# BASIC MOVEMENT VARIABLES ---------------- #
export(float, 0, 1) var run_threshold: float = 0.8 # set to 0 to disable walk detection
export var max_walk_speed: float = 100.0
export var max_run_speed: float = 280.0
export var acceleration: float = 1440.0
export var turning_acceleration : float = 4800.0
export var drag_deceleration: float = 1600.0

# GRAVITY ----- #
export var gravity_acceleration : float = 1920.0
export var gravity_max : float = 510.0


# JUMP VARIABLES ------------------- #
export var jump_force : float = 700.0
export var jump_cut : float = 0.25
export var jump_gravity_max : float = 250.0
export var jump_hang_treshold : float = 2.0
export var jump_hang_gravity_mult : float = 0.1
# Timers
export var jump_coyote : float = 0.08
export var jump_buffer : float = 0.1

var jump_coyote_timer : float = 0
var jump_buffer_timer : float = 0


#~ export_group("Dash Movement")
# TODO: Tune this in terms of distance instead of speed?
export(float, 10, 1000) var max_dash_speed: float = 860
export(float, 10, 1000) var dash_force : float = 1000
export(float, 1000, 9000) var dash_deceleration: float = 8480
export(float, 0, 10) var dash_cooldown : float = 0.05
export(float, 0, 10) var dash_duration : float = 0.2

var dash_cooldown_timer : float = -1.0
var dash_duration_timer : float = 0
var _is_dashing := false


#~ export_group("Climbing")
export(float, 10, 1000) var max_climb_speed := 200.0
export(float, 10, 1000) var climb_jump_speed := 500.0

var can_climb := false



onready var player_visual = get_node("%PlayerVisual")

var velocity := Vector2(0,0)
var face_direction := 1
var block_input := false
var is_jumping := false
var spawn_pos := Vector2(0,0)

onready var states = {
	default_state = $StateMachine/Default,
	freestyle = $StateMachine/Freestyle,
	climb = $StateMachine/Climb,
}


static func create_statemachine(parent : Node, all_states) -> StateMachine:
	var machine = StateMachine.new()
	machine.create_states(all_states)
	parent.add_child(machine)
	return machine


onready var sm : StateMachine = create_statemachine(self, states)


# All inputs we want to keep track of
func get_input() -> Dictionary:
	if block_input:
		return {
			"x": 0.0,
			"y": 0.0,
			"just_jump": false,
			"jump": false,
			"released_jump": false,
			"walk": false,
			"just_dash": false,
			"hold_dash": false,
			"released_dash": false,
		}
	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return {
		"x": move.x,
		"y": move.y,
		"just_jump": Input.is_action_just_pressed("action1"),
		"jump": Input.is_action_pressed("action1"),
		"released_jump": Input.is_action_just_released("action1"),
		"walk": false,  # Input.is_action_pressed("action2"),
		"just_dash": Input.is_action_just_pressed("action2"),
		"hold_dash": Input.is_action_pressed("action2"),
		"released_dash": Input.is_action_just_released("action2"),
	}


func _ready() -> void:
	Validate.ok(Broadcast_idbrii.connect("time_expired", self, "_on_time_expired"))
	Validate.ok(Broadcast_idbrii.connect("set_input_block", self, "_on_set_input_block"))
	Validate.ok(Broadcast_idbrii.connect("start_round", self, "_on_start_round"))
	for state_name in states:
		var state = states[state_name]
		state.sm = sm
		state.player = self
	#~ sm.add_label($ui_root/label_bookmark)
	sm.transition_to(states.freestyle, {})
	spawn_pos = global_position


func _on_time_expired():
	block_input = true


func _on_set_input_block(should_block):
	block_input = should_block


func _on_start_round():
	block_input = false
	global_position = spawn_pos
	if is_holding_dice():
		drop_grab_target()


func _physics_process(dt: float):
	sm.tick(dt)
	apply_velocity()
	if is_holding_dice() and get_input().just_dash:
		# Drop on dash
		drop_grab_target()

	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("dice"):
			collision.collider.apply_central_impulse(-collision.normal * push_strength)


func set_direction(hor_direction):
	# This is purely for visuals
	if hor_direction == 0:
		# No clear direction, so don't change.
		return
	#~ player_visual.scale = Vector2(abs(player_visual.scale.y) * hor_direction, player_visual.scale.y)
	face_direction = hor_direction # remember direction
	emit_signal("facing_flipped", hor_direction > 0)


const stop_on_slope = false
const max_slides = 4
const floor_max_angle = 0.785398
const infinite_inertia = false

func apply_velocity() -> void:
	if is_jumping:
		velocity = move_and_slide(velocity, Vector2.UP, stop_on_slope, max_slides, floor_max_angle, infinite_inertia)
	else:
		velocity = move_and_slide_with_snap(velocity, Vector2(0, 16), Vector2.UP, stop_on_slope, max_slides, floor_max_angle, infinite_inertia)


func is_dashing():
	return _is_dashing

func is_climbing():
	return sm.current() == sm.states.climb


# Grabbing {{{1
var grabbed_item : Node2D
var grab_parent : Node2D

func is_holding_dice():
	return grabbed_item != null

# For now, we auto grab on jump.
func set_grab_target(grabbable: RigidBody2D):
	if get_input().hold_dash or grabbed_item:
		# Ignore while dashing or holding.
		return
	grabbed_item = grabbable
	grab_parent = grabbed_item.get_parent()
	grabbed_item.picked_up_by(self)
	grab_parent.remove_child(grabbed_item)
	$DiceHolder.add_child(grabbed_item)
	grabbed_item.position = Vector2.ZERO


func clear_grab_target(grabbable):
	# We left the grabbable's grab zone. Ignored for now since we grab on contact.
	if false and grabbed_item == grabbable:
		drop_grab_target()

func drop_grab_target():
	var pos = grabbed_item.global_position
	$DiceHolder.remove_child(grabbed_item)
	grab_parent.add_child(grabbed_item)
	grabbed_item.global_position = pos
	grabbed_item.dropped_by(self)
	var impulse = Vector2.RIGHT * face_direction * throw_forward_strength + Vector2.UP * throw_up_strength
	grabbed_item.apply_central_impulse(impulse)
	grabbed_item = null
	grab_parent = null

