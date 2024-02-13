extends KinematicBody2D

export var maxSpeed = 450
export var acceleration = 300
export var reverseAcceleration = 450
export var boostModifier = 1.6

var speed = 0 

func _ready():
	pass

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
		speed = move_toward(speed, 0, acceleration * delta)
	else:
		var activeAcceleration = 0
		if abs(speed) > 0 && sign(direction) != sign(speed):
			activeAcceleration = reverseAcceleration * modifier
		else:
			activeAcceleration = acceleration * modifier
		
		speed += direction * activeAcceleration * delta
	
	var activeMaxSpeed = maxSpeed * modifier
	speed = clamp(speed, -activeMaxSpeed, activeMaxSpeed)
	
	var collision = move_and_collide(Vector2.RIGHT * speed * delta)
	if collision != null:
		speed = 0
	
	pass
