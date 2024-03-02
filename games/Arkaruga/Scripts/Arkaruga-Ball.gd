extends KinematicBody2D

const Types = preload("res://games/Arkaruga/Scripts/Arkaruga-Types.gd")
const Paddle = preload("res://games/Arkaruga/Scripts/Arkaruga-Paddle.gd")

export var baseSpeed : float = 200
export var minSpeed : float = 150
export var maxSpeed : float = 300
export var gravity : float = 10
export var paddleSpeedRatio : float = .5
export var paddlePositionRatio : float = .5
export var minPaddleComponentBounceVerticalComponent : float = .25
export var textureBlue : Texture
export var textureGreen : Texture

onready var _sprite : Sprite = $Sprite
onready var _trail = $Trail

var _manager
var _ballContainer

var _velocity : Vector2
var _attachedPaddle : KinematicBody2D
var _color
	
func _process(delta):
	if _attachedPaddle == null:
		var offset = _velocity * delta
		var collision := move_and_collide(offset)
		if collision != null:
			if collision.travel.length_squared() > 0:
				processCollision(collision)
			else:
				position += offset
				
		_velocity.y += gravity * delta
		
func initialize(manager, ballContainer):
	_manager = manager
	_ballContainer = ballContainer
			
func onActiveColorChanged(color: int):
	_setColor(color)

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
	
	# notify the other collider
	if collision.collider.has_method("onBallHit"):
		collision.collider.onBallHit(self)

func setVelocity(velocity: Vector2):
	_velocity = velocity

func attachToPaddle(paddle: KinematicBody2D):
	# attach ourselves to the paddle's anchor
	_attachedPaddle = paddle
	_attachedPaddle.ballAnchor.add_child(self)
	position = Vector2.ZERO

func startLaunchTimer():
	# TODO: show countdown in UI
	yield(get_tree().create_timer(1), "timeout")
	print("3")
	yield(get_tree().create_timer(1), "timeout")
	print("2")
	yield(get_tree().create_timer(1), "timeout")
	print("1")
	yield(get_tree().create_timer(1), "timeout")
	
	# detach from paddle
	var globalPosition = global_position
	if get_parent():
		get_parent().remove_child(self)

	# add to ball container, preserving our position
	_ballContainer.add_child(self)
	global_position = globalPosition
	
	# set our velocity
	_velocity = Vector2.UP * baseSpeed
	if _attachedPaddle != null:
		_velocity += _attachedPaddle.getVelocity()
		
	# enable our trail
	if _trail:
		_trail.emitting = true
	
	# mark ourselves as detached
	_attachedPaddle = null	

func _setColor(color: int):
	_color = color
	match color:
		Types.ElementColor.BLUE:
			_sprite.texture = textureBlue
		Types.ElementColor.GREEN:
			_sprite.texture = textureGreen
	pass


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	if _attachedPaddle == null && !is_queued_for_deletion():
		_manager.onBallLost(self)
		queue_free()
