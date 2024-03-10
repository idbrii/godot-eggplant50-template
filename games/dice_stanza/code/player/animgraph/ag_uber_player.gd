extends Node

const Validate = preload("res://games/dice_stanza/code/util/validate.gd")
const Vec = preload("res://games/dice_stanza/code/util/vec.gd")


var ag
var sm


func _is_falling(vel):
	return vel.y > 0

func _is_soaring(vel):
	return vel.y < 0

func _is_run(vel):
	return vel.x != 0

# wrapper function to allow printing or other debugging
func _play_anim(anim):
	ag._sprite_animator.play(anim)
func _play_fx(anim):
	ag._scale_animator.play(anim)


func _compute_state():
	# Can transition from any state to these based on these conditions. Order
	# is very important.
	if ag.player.block_input:
		return ag.states.dead
	if ag.player.is_climbing():
		return ag.states.climb
	if ag.player.is_dashing():
		return ag.states.dash
	if _is_soaring(ag.player.velocity):
		return ag.states.jump
	if _is_falling(ag.player.velocity):
		return ag.states.fall

func _update_state_generic(_dt):
	var dest = _compute_state()
	if dest and dest != sm.current():
		return sm.transition_to(dest, {})


func _update_state_dead(dt):
	return _update_state_generic(dt)


func _update_state_fall(dt):
	if ag.player.is_on_floor():
		return sm.transition_to(ag.states.land, {})
	return _update_state_generic(dt)


func _update_state_jump(dt):
	if ag.player.is_on_floor():
		return sm.transition_to(ag.states.ground_idle, {})
	if _is_falling(ag.player.velocity):
		return sm.transition_to(ag.states.fall, {})
	return _update_state_generic(dt)

func _update_state_ground_idle(dt):
	if ag.player.is_on_floor() and _is_run(ag.player.velocity):
		return sm.transition_to(ag.states.ground_run, {})
	return _update_state_generic(dt)


func _update_state_ground_run(dt):
	if ag.player.is_on_floor() and not _is_run(ag.player.velocity):
		return sm.transition_to(ag.states.ground_idle, {})
	return _update_state_generic(dt)


func _update_state_climb(dt):
	if Vec.is_zero_approx(ag.player.velocity):
		ag._sprite_animator.stop()
	else:
		ag._sprite_animator.play()

	if ag.player.is_on_floor():
		return sm.transition_to(ag.states.ground_idle, {})
	return _update_state_generic(dt)


func _update_state_dash(dt):
	if not ag.player.is_dashing():
		return _update_state_generic(dt)


func _enter_state_climb(_data):
	_play_anim("ladder")

func _enter_state_dead(_data):
	_play_anim("dead")

func _enter_state_jump(_data):
	_play_anim("jump")
	_play_fx("Jump")
	ag.sounds.jump.play()

func _enter_state_fall(_data):
	_play_anim("fall")

func _enter_state_land(_data):
	_play_anim("land")
	_play_fx("Land")
	ag.sounds.hit.play()
	# Delay to see the full animation.
	for i in 10:
		yield(get_tree(), "idle_frame")
	sm.transition_to(ag.states.ground_idle, {})

func _enter_state_dash(_data):
	_play_anim("dash_left")

func _enter_state_ground_idle(_data):
	_play_anim("idle")

func _enter_state_ground_run(_data):
	_play_anim("run")
