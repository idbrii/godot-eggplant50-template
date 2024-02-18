extends KinematicBody2D

const Paddle = preload("res://games/Arkaruga/Scripts/Arkaruga-Paddle.gd")

export var baseSpeed : float = 200
export var minSpeed : float = 150
export var maxSpeed : float = 300
export var paddleSpeedRatio : float = .5
export var paddlePositionRatio : float = .5
export var minPaddleComponentBounceVerticalComponent : float = .25

var _velocity;

func _ready():
	_velocity = Vector2.DOWN * baseSpeed
	
func _process(delta):
	var collision = move_and_collide(_velocity * delta)
	if collision != null:
		processCollision(collision)

func processCollision(collision):
	# perform default bouncing
	_velocity = _velocity.bounce(collision.normal)
	
	var direction = _velocity.normalized()
	move_and_collide(direction * collision.remainder)
	
	# modify the velocity based on colliding with the paddle
	var paddle := collision.collider as Paddle
	if paddle:
		# alter our bounce based on where on the paddle we land
		var bounceDirection = paddle.getBounceDirectionFromPosition(collision.position)
		bounceDirection = lerp(direction, bounceDirection, paddlePositionRatio)
		if bounceDirection.length_squared() > 0:
			_velocity = bounceDirection.normalized() * _velocity.length()
		
		# add the paddle's own velocity to our bounce
		_velocity += (paddle.getVelocity() * paddleSpeedRatio)
	
	# cap our max speed
	var finalSpeed = clamp(_velocity.length(), minSpeed, maxSpeed)
	var finalDirection = _velocity.normalized()
	if paddle != null && finalDirection.y > -minPaddleComponentBounceVerticalComponent:
		finalDirection.y = -minPaddleComponentBounceVerticalComponent
		finalDirection = finalDirection.normalized()
	
	_velocity = finalDirection * finalSpeed