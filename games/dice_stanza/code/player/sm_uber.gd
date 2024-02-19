extends Node
# Godot3 doesn't have first-class functions, so we build our statemachine out
# of multiple nodes. It's hard to share code between those nodes, so we have
# this monster class for common functionality that each state can use.

# NB: None of this state or tuning is shared between states! Tune in code and
# access shared state on player.


const Vec = preload("res://games/dice_stanza/code/util/vec.gd")


# State Machine {{{1
var sm  # StateMachine
var player : KinematicBody2D

func _physics_process(dt: float) -> void:
	_tick_timers(dt)

func set_block_input(should_block):
	player.block_input = should_block
	if should_block:
		player.velocity = Vector2.ZERO

func _state_is_supported_by_floor():
	return player.is_on_floor()

func _enter_state_freestyle(_data):
	player.jump_coyote_timer = 0
	player.jump_buffer_timer = 0
	player.is_jumping = false

func _update_state_freestyle(dt):
	var input = player.get_input()
	if not input.jump and player.can_climb and abs(input.y) > 0:
		sm.transition_to(sm.states.climb, {})
		return
	x_movement(dt)
	dash_logic(dt)
	var _jumped = jump_logic(dt)
	apply_gravity(dt)


func reset_state(state):
	state.should_apply = false
	state.should_abort = false
	return state

func brake_from_drag(dt, state, input, brake_accel):
	if abs(input) <= 0.1 or (state.max_speed > 0 and abs(state.vel) >= state.max_speed):
		# Brake if we're not doing movement inputs or slowing to walk
		state.vel = move_toward(state.vel, 0, brake_accel * dt)
		state.should_apply = true
		state.should_abort = true
	return state

func accelerate_from_input(dt, state, input, fwd_accel, rev_accel):
	var input_follows_momentum_dir = sign(state.vel) == sign(input)

	# If we are doing movement inputs and above max speed, don't accelerate nor
	# decelerate except if we are turning or walking to keep our momentum
	# gained from outside or slopes.
	# TODO: Should this also check not is_walking?
	if abs(state.vel) >= state.max_speed and input_follows_momentum_dir:
		state.should_abort = true
		return

	# Are we turning?
	# Deciding between player.acceleration and turn_acceleration
	var accel_rate : float = fwd_accel if input_follows_momentum_dir else rev_accel

	# Accelerate
	state.vel += input * accel_rate * dt
	state.should_apply = true
	return state

func x_movement(dt: float) -> void:
	var input = player.get_input()
	var x_val = input.x
	var x_abs = abs(x_val)
	var x_sign = sign(x_val)
	var x_int = int(ceil(x_abs) * x_sign)
	var is_walking = x_abs < player.run_threshold or input.walk

	var state = reset_state({
		vel = player.velocity.x,
		max_speed = player.max_walk_speed if is_walking else 0.0, # 0 is no maximum
	})
	brake_from_drag(dt, state, x_val, player.drag_deceleration)
	if state.should_apply:
		player.velocity.x = state.vel
	if state.should_abort:
		return

	reset_state(state)
	state.max_speed = player.max_run_speed
	if is_dashing():
		# Lets us increase our dash distance by holding a
		# direction during the dash. Good idea?
		state.max_speed = player.max_dash_speed
	accelerate_from_input(dt, state, x_val, player.acceleration, player.turning_acceleration)
	if state.should_apply:
		player.velocity.x = state.vel
	if state.should_abort:
		return

	player.set_direction(round(x_int)) # This is purely for visuals


# Jumping {{{1

func jump_logic(_delta: float) -> bool:
	# Reset our jump requirements
	if sm.current().is_supported():
		player.jump_coyote_timer = player.jump_coyote
		player.is_jumping = false
	if player.get_input().just_jump:
		player.jump_buffer_timer = player.jump_buffer

	# Jump if grounded, there is jump input, and we aren't jumping already
	if ticking(player.jump_coyote_timer) and ticking(player.jump_buffer_timer) and not player.is_jumping:
		player.is_jumping = true
		player.jump_coyote_timer = 0
		player.jump_buffer_timer = 0
		# If falling, account for that lost speed
		if player.velocity.y > 0:
			player.velocity.y -= player.velocity.y

		player.velocity.y = -player.jump_force

	# We're not actually interested in checking if the player is holding the
	# jump button. We only care about press and release.
	# if player.get_input().jump:pass

	# Cut the player.velocity if let go of jump. This means our jumpheight is variable
	# This should only happen when moving upwards, as doing this while falling would lead to
	# The ability to stutter our player mid falling
	if player.get_input().released_jump and player.velocity.y < 0:
		player.velocity.y -= (player.jump_cut * player.velocity.y)

	# This way we won't start slowly descending / floating once hit a ceiling
	# The value added to the threshold is arbitrary,
	# But it solves a problem where jumping into
	if player.is_on_ceiling():
		player.velocity.y = player.jump_hang_treshold + 100.0

	return player.is_jumping


func apply_gravity(delta: float) -> void:
	var applied_gravity : float = 0

	# No gravity if we are grounded
	if ticking(player.jump_coyote_timer):
		return

	# Normal gravity limit
	if player.velocity.y <= player.gravity_max:
		applied_gravity = player.gravity_acceleration * delta

	# If moving upwards while jumping, the limit is player.jump_gravity_max to achieve lower gravity
	if (player.is_jumping and player.velocity.y < 0) and player.velocity.y > player.jump_gravity_max:
		applied_gravity = 0

	# Lower the gravity at the peak of our jump (where player.velocity is the smallest)
	if player.is_jumping and abs(player.velocity.y) < player.jump_hang_treshold:
		applied_gravity *= player.jump_hang_gravity_mult

	player.velocity.y += applied_gravity


func _tick_timers(dt: float) -> void:
	# Using timer nodes here would mean unnecessary functions and node calls
	# This way everything is contained in just 1 script with no node requirements
	player.jump_coyote_timer -= dt
	player.jump_buffer_timer -= dt
	player.dash_cooldown_timer -= dt
	player.dash_duration_timer -= dt

# Could be static, but don't want the warning.
func expired(timer: float) -> bool:
	return timer <= 0
func ticking(timer: float) -> bool:
	return not expired(timer)


# Dashing {{{1

func is_dashing():
	return player._is_dashing

func dash_logic(_dt):
	var input = player.get_input()
	var was_dashing = player._is_dashing
	player._is_dashing = player._is_dashing and input.hold_dash and not expired(player.dash_duration_timer)

	if player.is_holding_dice():
		player._is_dashing = false
		player.dash_cooldown_timer = player.dash_cooldown

	if was_dashing and not player._is_dashing:
		# Once we stopped dashing, truncate speed to run.
		player.velocity = player.velocity.limit_length(player.max_run_speed)
		player.dash_duration_timer = 0

	elif input.just_dash and expired(player.dash_cooldown_timer):
		player._is_dashing = true
		player.dash_duration_timer = player.dash_duration
		var dir = Vector2(input.x, input.y)
		if Vec.is_zero_approx(dir):
			dir = player.velocity
		if Vec.is_zero_approx(dir):
			dir = Vector2(player.face_direction, 0)
		dir = dir.normalized()
		# TODO: Should this set the player.velocity so dash has a limited distance?
		player.velocity += dir * player.dash_force

	# Cooldown starts once dash ends, so never let timer expire during dash.
	if player._is_dashing:
		player.dash_cooldown_timer = player.dash_cooldown



# Climbing {{{1

func is_climbing():
	return sm.current() == sm.states.climb

func _enter_state_climb(_data):
	# Remove speed so you don't fall off the climb
	player.velocity = Vector2.ZERO

func _update_state_climb(dt):
	# CONSIDER: Maybe should use coyote time to allow you to keep climbing if
	# you missed a climb?
	if not player.can_climb:
		sm.transition_to(sm.states.freestyle, {})
		return
	if jump_logic(dt):
		sm.transition_to(sm.states.freestyle, {})
		# Make jumps off of climbs huge because you can't climb horizontally fast.
		# TODO: project onto velocity to prevent huge vertical jumps?
		player.velocity.x = sign(player.velocity.x) * player.climb_jump_speed
		return
	climb_movement(dt)

func set_can_climb(is_allowed):
	player.can_climb = is_allowed

func climb_movement(dt: float) -> void:
	var input = player.get_input()

	var x_state = reset_state({
		vel = player.velocity.x,
		max_speed = player.max_climb_speed,
	})
	var y_state = reset_state({
		vel = player.velocity.y,
		max_speed = player.max_climb_speed,
	})
	brake_from_drag(dt, x_state, input.x, player.drag_deceleration)
	brake_from_drag(dt, y_state, input.y, player.drag_deceleration)
	if x_state.should_apply and y_state.should_apply:
		player.velocity.x = x_state.vel
		player.velocity.y = y_state.vel
		return

	reset_state(x_state)
	reset_state(y_state)
	accelerate_from_input(dt, x_state, input.x, player.acceleration, player.turning_acceleration)
	accelerate_from_input(dt, y_state, input.y, player.acceleration, player.turning_acceleration)
	if x_state.should_apply:
		player.velocity.x = x_state.vel
	if y_state.should_apply:
		player.velocity.y = y_state.vel
	if x_state.should_abort and y_state.should_abort:
		return

