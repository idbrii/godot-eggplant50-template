extends RigidBody2D

const MAX_SPEED = 100

var knocks = 0
var previously_touched

func _ready() -> void:
	previously_touched = self
	$DragTimer.connect('timeout', self, 'drag_timeout')
	$PopTimer.connect('timeout', self, 'pop_timeout')
	connect('body_entered', self, 'on_body_entered')

func _physics_process(_delta: float) -> void:
	if linear_velocity.length() > MAX_SPEED and $DragTimer.is_stopped():
		linear_damp = 0.5
		$DragTimer.start()

func drag_timeout() -> void:
	linear_damp = -1

func on_body_entered(body) -> void:
	if previously_touched == body:
		return
	print("knocked into ", body)
	if $PopTimer.is_stopped():
		$PopTimer.start()
	elif knocks > 3:
		print("pop! ", knocks)

	knocks += 1

func pop_timeout() -> void:
	knocks = 0
	print("pop avoided")
