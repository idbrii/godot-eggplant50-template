extends KinematicBody2D

export var maxSpeed : float = 450
export var acceleration : float = 300
export var reverseAcceleration : float = 450
export var boostModifier : float = 1.6
export var maxBounceAngle : float = 80

var _speed : float = 0

func _ready():
	pass
	
func _input(event):
	if event.is_action_pressed("action1"):
		print("Toggle!")
		# toggle();

func _process(delta):
	var direction = 0
	if Input.is_action_pressed("move_left"):
		direction = -1
	if Input.is_action_pressed("move_right"):
		direction = 1
		
	var isBoosting = Input.is_action_pressed("action2")
	var modifier = boostModifier if isBoosting else 1
	
	if direction == 0:
		# slow back down to 0
		_speed = move_toward(_speed, 0, acceleration * delta)
	else:
		var activeAcceleration = 0
		if abs(_speed) > 0 && sign(direction) != sign(_speed):
			activeAcceleration = reverseAcceleration * modifier
		else:
			activeAcceleration = acceleration * modifier
		
		_speed += direction * activeAcceleration * delta
	
	var activeMaxSpeed = maxSpeed * modifier
	_speed = clamp(_speed, -activeMaxSpeed, activeMaxSpeed)
	
	
	var collision = move_and_collide(Vector2.RIGHT * _speed * delta)
	if collision != null:
		if collision.collider.is_in_group("Balls"):
			# don't let the ball stop us
			# we should be able to fix this via collision layers/masks
			# but until 4.0 it's impossible to do one-way collision detection. Fun!
			position += collision.remainder
		else:
			# stop our velocity
			_speed = 0
		
	return

func getVelocity() -> Vector2:
	return Vector2.RIGHT * _speed

func getBounceDirectionFromPosition(position) -> Vector2:
	var collider := $Collision as CollisionShape2D
	var shape := collider.shape as RectangleShape2D
	var width = shape.extents.x
	var offset = position.x - collider.global_position.x
	var normalizedBounceDirection = clamp(offset / width, -1, 1)
	var bounceAngle = normalizedBounceDirection * maxBounceAngle
	
	return Vector2.UP.rotated(deg2rad(bounceAngle))
	
	
	
	
