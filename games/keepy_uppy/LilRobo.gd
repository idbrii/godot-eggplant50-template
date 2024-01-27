extends KinematicBody2D

export (int) var run_speed = 90
export (int) var dash_speed = 90
export (int) var jump_speed = -130
export (int) var gravity = 1100

var dashing = false

var velocity = Vector2()
var jumping = false

func _ready():
	$DashTimer.connect('timeout', self, 'stop_dash')

func stop_dash():
	dashing = false

func get_input():
	velocity.x = 0
	var right = Input.is_action_pressed('move_right')
	var left = Input.is_action_pressed('move_left')
	var jump = Input.is_action_just_pressed('move_up')

	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed
	if Input.is_action_pressed('action1') and $DashTimer.is_stopped():
		dashing = true
		var dash = get_tree().create_tween()
		dash.tween_property(self, 'run_speed', run_speed, 0.99)
		run_speed += dash_speed
		$DashTimer.start()

	var accel = run_speed
	if right:
		velocity.x += accel
	if left:
		velocity.x -= accel

func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	if jumping and is_on_floor():
		jumping = false
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
