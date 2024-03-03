extends KinematicBody2D

const Types = preload("res://games/Arkaruga/Scripts/Arkaruga-Types.gd")

export var maxSpeed : float = 450
export var acceleration : float = 300
export var reverseAcceleration : float = 450
export var boostModifier : float = 1.8
export var maxBounceAngle : float = 80
export var bumperTextureBlue : Texture
export var bumperTextureGreen : Texture
export var alarmTextureBlue : Texture
export var alarmTextureGreen : Texture
export var damageFreezeDuration = 1
export var hitBumperFlashDuration = .2

onready var _manager : Node2D = get_tree().get_nodes_in_group("Manager")[0]

onready var ballAnchor : Node2D = $BallAnchor
onready var _collisionShape : CollisionShape2D = $Collision
onready var _bumper : NinePatchRect = $Body/Bumper
onready var _hitBumper : NinePatchRect = $Body/Bumper/HitBumper
onready var _alarm : NinePatchRect = $Body/Alarm
onready var _alertGroup : Control = $Body/Alert
onready var _alertTimer : Timer = $Body/Alert/Timer
onready var _alertFrame1 : Control = $Body/Alert/Frame1
onready var _alertFrame2 : Control = $Body/Alert/Frame2
onready var _freezeTimer : Timer = $FreezeTimer
onready var _flashTimer : Timer = $FlashTimer

onready var _damageSFX : AudioStreamPlayer = $DamageSFX
onready var _damageParticles : CPUParticles2D = $DamageParticles

var _speed : float = 0
var _isFrozen = false
var _isFlashingHitBumper = false
var _color

func _ready():
	_hitBumper.visible = false
	pass
	
func _process(delta):
	var canMove = !_isFrozen
	if canMove:
		_processMovement(delta)
	
func _processMovement(delta: float):
	var direction = 0
	if _manager && _manager.getIsGameRunning():
		if Input.is_action_pressed("move_left"):
			direction = -1
		if Input.is_action_pressed("move_right"):
			direction = 1
		
	var isBoosting = Input.is_action_pressed("action2")
	var modifier = boostModifier if isBoosting else 1.0

	if direction == 0:
		# slow back down to 0
		_speed = move_toward(_speed, 0, acceleration * delta)
	else:
		var activeAcceleration = 0
		if abs(_speed) > 0 && sign(direction) != sign(_speed):
			# ignore our modifier when reversing
			activeAcceleration = reverseAcceleration
		else:
			activeAcceleration = acceleration * modifier
		
		_speed += direction * activeAcceleration * delta
	
	var activeMaxSpeed = maxSpeed * modifier
	_speed = clamp(_speed, -activeMaxSpeed, activeMaxSpeed)
	
	var prevPosition = position
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
			
	# don't allow move-and-collide to push us vertically
	if position.y != prevPosition.y:
		position.y = prevPosition.y
	
func onActiveColorChanged(color: int):
	_setColor(color)
	
func onBallHit(_ball):
	_flashHitBumper(hitBumperFlashDuration)
	return false

func onFallingBrickHit(_block):
	_freeze(damageFreezeDuration)

func getVelocity() -> Vector2:
	return Vector2.RIGHT * _speed

func getBounceDirectionFromPosition(position : Vector2) -> Vector2:
	var shape := _collisionShape.shape as RectangleShape2D
	var width = shape.extents.x
	var offset = position.x - _collisionShape.global_position.x
	var normalizedBounceDirection = clamp(offset / width, -1, 1)
	var bounceAngle = normalizedBounceDirection * maxBounceAngle
	
	return Vector2.UP.rotated(deg2rad(bounceAngle))
	
func _setColor(color: int):
	_color = color
	match color:
		Types.ElementColor.BLUE:
			_bumper.texture = bumperTextureBlue
			_alarm.texture = alarmTextureBlue
		Types.ElementColor.GREEN:
			_bumper.texture = bumperTextureGreen
			_alarm.texture = alarmTextureGreen
	pass

func _freeze(duration: float):
	if _isFrozen:
		return
		
	_isFrozen = true
	_alertGroup.visible = true
	_alertFrame1.visible = true
	_alertFrame2.visible = false
	_alertTimer.start()
	_speed = 0
	
	_damageSFX.play()
	_damageParticles.emitting = true
	
	_freezeTimer.start(duration)
	yield(_freezeTimer, "timeout")
	
	_alertGroup.visible = false
	_alertTimer.stop()
	_isFrozen = false

func _flashHitBumper(duration: float):
	if _isFlashingHitBumper:
		return
	
	_isFlashingHitBumper = true
	_hitBumper.visible = true
	
	_flashTimer.start(duration)
	yield(_flashTimer, "timeout")
	
	_hitBumper.visible = false
	_isFlashingHitBumper = false

func _on_AlertTimer_timeout():
	_alertFrame1.visible = !_alertFrame1.visible
	_alertFrame2.visible = !_alertFrame2.visible
