extends KinematicBody2D

const Types = preload("res://games/Arkaruga/Scripts/Arkaruga-Types.gd")
const Paddle = preload("res://games/Arkaruga/Scripts/Arkaruga-Paddle.gd")

export var countdownDuration : float = 1
export var baseSpeed : float = 200
export var minSpeed : float = 150
export var maxSpeed : float = 300
export var maxSpeedModifier : float = 2.5
export var gravity : float = 10
export var paddleSpeedRatio : float = .5
export var paddlePositionRatio : float = .5
export var minPaddleComponentBounceVerticalComponent : float = .25
export var textureBlue : Texture
export var textureGreen : Texture

onready var _manager : Node2D = get_tree().get_nodes_in_group("Manager")[0]
onready var _sprite : Sprite = $Sprite
onready var _trail = $Trail
onready var _countdownTimer : Timer = $CountdownTimer

var _velocity : Vector2
var _attachedPaddle : KinematicBody2D
var _color

func _ready():
	if _manager:
		onActiveColorChanged(_manager.activeColor)
	
func _process(delta):
	if _attachedPaddle == null:
		var offset = _velocity * delta
		if _manager != null:
			var speedModifier = lerp(1.0, maxSpeedModifier, _manager.getSpeedModifierRatio())
			offset *= speedModifier
		
		var collision := move_and_collide(offset)
		if collision != null:
			if collision.travel.length_squared() > 0:
				processCollision(collision)
			else:
				position += offset
				
		_velocity.y += gravity * delta
				
func onActiveColorChanged(color: int):
	_setColor(color)
	
func getIsActive():
	return _attachedPaddle == null && !is_queued_for_deletion()

func processCollision(collision):
	# perform default bouncing
	_velocity = _velocity.bounce(collision.normal)
	
	var direction = _velocity.normalized()
	var _remainderCollision = move_and_collide(direction * collision.remainder)
	
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
		
	# increase our combo
	if _manager:
		if paddle:
			_manager.resetCombo()
		else:
			_manager.addCombo()

func attachToPaddle(paddle: KinematicBody2D):
	# attach ourselves to the paddle's anchor
	_attachedPaddle = paddle
	_attachedPaddle.ballAnchor.add_child(self)
	position = Vector2.ZERO

func startLaunchTimer():
	# TODO: show countdown in UI
	_countdownTimer.start(countdownDuration)
	yield(_countdownTimer, "timeout")
	
	if _manager:
		_manager.uiManager.playToast(str(3))
	
	_countdownTimer.start(countdownDuration)
	yield(_countdownTimer, "timeout")
	
	if _manager:
		_manager.uiManager.playToast(str(2))
	
	_countdownTimer.start(countdownDuration)
	yield(_countdownTimer, "timeout")
	
	if _manager:
		_manager.uiManager.playToast(str(1))
	
	_countdownTimer.start(countdownDuration)
	yield(_countdownTimer, "timeout")
	
	if _manager:
		_manager.uiManager.playToast("Go!")
	
	# detach from paddle
	var globalPosition = global_position
	if get_parent():
		get_parent().remove_child(self)

	# add to ball container, preserving our position
	_manager.ballContainer.add_child(self)
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


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	if _attachedPaddle == null && !is_queued_for_deletion():
		queue_free()
		_manager.onBallLost(self)

