extends RigidBody2D

enum BalloonState {
	IN_PLAY,
	POPPED
}

const MAX_SPEED = 100

signal touch_update(count)
signal balloon_popped(balloon)
signal floor_touched()

var knocks = 0
var keep_up_touches = 0
var previously_touched
var current_state = BalloonState.IN_PLAY

func _ready() -> void:
	knocks = 0
	keep_up_touches = 0
	previously_touched = self
	current_state = BalloonState.IN_PLAY

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

	print("knocked into ", body)
	if $PopTimer.is_stopped():
		$PopTimer.start()
	elif knocks > 3:
		print("pop! ", knocks)
		emit_signal('balloon_popped', self)
		current_state = BalloonState.POPPED
	
	knocks += 1

	previously_touched = body

func pop_timeout() -> void:
	knocks = 0
	print("pop avoided")
