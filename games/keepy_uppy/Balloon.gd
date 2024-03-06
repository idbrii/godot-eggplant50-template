extends RigidBody2D

export(AudioStreamSample) var bounce1 = preload('res://games/keepy_uppy/balloon-bounce1.wav')
export(AudioStreamSample) var bounce2 = preload('res://games/keepy_uppy/balloon-bounce2.wav')
export(AudioStreamSample) var bounce3 = preload('res://games/keepy_uppy/balloon-bounce3.wav')

export(AudioStreamSample) var short_bounce1 = preload('res://games/keepy_uppy/balloon-short-bounce1.wav')
export(AudioStreamSample) var short_bounce2 = preload('res://games/keepy_uppy/balloon-short-bounce2.wav')
export(AudioStreamSample) var short_bounce3 = preload('res://games/keepy_uppy/balloon-short-bounce3.wav')

export(AudioStreamSample) var explode_sound = preload('res://games/keepy_uppy/explosion.wav')

enum BalloonState {
	IN_PLAY,
	POPPED
}

const MAX_SPEED = 100

signal touch_update(count)
signal balloon_popped(balloon)
signal floor_touched()

var knocks : int = 0
var keep_up_touches : int = 0
var previously_touched
var current_state = BalloonState.IN_PLAY
var last_bounce : int = 0

func _ready() -> void:
	knocks = 0
	keep_up_touches = 0
	previously_touched = self
	current_state = BalloonState.IN_PLAY
	last_bounce = Time.get_ticks_msec()

	$DragTimer.connect('timeout', self, 'drag_timeout')
	$PopTimer.connect('timeout', self, 'pop_timeout')
	connect('body_entered', self, 'on_body_entered')

func _physics_process(_delta: float) -> void:
	if linear_velocity.length() > MAX_SPEED and $DragTimer.is_stopped():
		linear_damp = 0.5
		$DragTimer.start()

func drag_timeout() -> void:
	linear_damp = -1

func was_previous_touch(body):
	return previously_touched == body

func on_body_entered(body) -> void:
	if current_state == BalloonState.POPPED:
		return

	if body == $'../LilRobo':
		keep_up_touches += 1
		emit_signal('touch_update', keep_up_touches)

	if body == $'../Room/Floor':
		keep_up_touches = 0
		emit_signal('touch_update', keep_up_touches)
		emit_signal('floor_touched')

	play_bounce()
	last_bounce = Time.get_ticks_msec()

	print("knocked into ", body)
	if $PopTimer.is_stopped():
		$PopTimer.start()
	elif knocks > 3:
		print("pop! ", knocks)
		emit_signal('balloon_popped', self)
		current_state = BalloonState.POPPED
		$AudioStreamPlayer.stop()
		$AudioStreamPlayer.stream = explode_sound
		$AudioStreamPlayer.play()
	
	knocks += 1

	previously_touched = body

onready var normal_sounds = [bounce1, bounce2, bounce3]
onready var short_sounds  = [short_bounce1, short_bounce2, short_bounce3]
func play_bounce():
	var is_short_sound : bool = Time.get_ticks_msec() - last_bounce < 250
	var sound : AudioStreamSample = (short_sounds if is_short_sound else normal_sounds)[randi() % 3]
	$AudioStreamPlayer.stream = sound
	$AudioStreamPlayer.play()

func pop_timeout() -> void:
	knocks = 0
	print("pop avoided")
