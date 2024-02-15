extends KinematicBody2D

const Paddle = preload("res://games/Arkaruga/Scripts/Arkaruga-Paddle.gd")
export var baseSpeed = 200
export var minSpeed = 150
export var maxSpeed = 300
export var paddleSpeedRatio = .5
export var paddlePositionRatio = .5
export var minPaddleComponentBounceVerticalComponent = .25

var velocity;

func _ready():
	velocity = Vector2.DOWN * baseSpeed
	
func _process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		processCollision(collision)

func processCollision(collision):
	# perform default bouncing
	velocity = velocity.bounce(collision.normal)
	
	var direction = velocity.normalized()
	move_and_collide(direction * collision.remainder)
	
	# modify the velocity based on colliding with the paddle
	var paddle := collision.collider as Paddle
	if paddle:
		# alter our bounce based on where on the paddle we land
		var bounceDirection = paddle.getBounceDirectionFromPosition(collision.position)
		bounceDirection = lerp(direction, bounceDirection, paddlePositionRatio)
		if bounceDirection.length_squared() > 0:
			velocity = bounceDirection.normalized() * velocity.length()
		
		# add the paddle's own velocity to our bounce
		velocity += (paddle.getVelocity() * paddleSpeedRatio)
	
	# cap our max speed
	var finalSpeed = clamp(velocity.length(), minSpeed, maxSpeed)
	var finalDirection = velocity.normalized()
	if paddle != null && finalDirection.y > -minPaddleComponentBounceVerticalComponent:
		finalDirection.y = -minPaddleComponentBounceVerticalComponent
		finalDirection = finalDirection.normalized()
	
	velocity = finalDirection * finalSpeed
		
func isBall():
	return true
