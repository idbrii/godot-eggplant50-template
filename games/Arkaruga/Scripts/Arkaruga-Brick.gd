extends KinematicBody2D

const Types = preload("res://games/Arkaruga/Scripts/Arkaruga-Types.gd")

export(Types.ElementColor) var color = Types.ElementColor.BLUE
export var maxHealth = 1
export var fallAtZeroHealth = false
export var points = 1
export var flashColor = Color.white
export var flashDuration = .033
export var gutterFallMaxDelay = 1
export var fallJumpSpeed = 200.0
export var maxFallSpeed = 200.0
export var fallMinAngleOffset = 10.0
export var fallMaxAngleOffset = 40.0
export var fallAcceleration = 600

onready var _manager : Node2D = get_tree().get_nodes_in_group("Manager")[0]
onready var _activeSprite : Sprite = $ActiveSprite
onready var _inactiveSprite : Sprite = $InactiveSprite
onready var _flashSprite : Sprite = $FlashSprite
onready var _collision : CollisionShape2D = $Collision
onready var _fallingArea : Area2D = $FallingDamageArea
onready var _flashTimer : Timer = $FlashTimer
onready var _gutterTimer : Timer = $GutterTimer
onready var _fallSFX : AudioStreamPlayer = $BlockFallSFX

onready var _health = maxHealth

var _isActive = true
var _isFlashing = false
var _isDestroyed = false
var _isFalling = false
var _fallSpeed = 0.0
var _isReparenting = false

func _ready():
	_flashSprite.visible = false
	if _manager:
		onActiveColorChanged(_manager.activeColor)
	pass
	
func _process(delta):
	if _isFalling:
		_updateFalling(delta)
		
	if _isDestroyed and !_isFlashing:
		queue_free()
	
func onActiveColorChanged(_color: int):
	if _canChangeColor():
		_setActive(_color == self.color)
		
func onBallHit(_ball):
	if _health > 0:
		_takeDamage(1)
		return true
	return false

func onGutterEntered():
	var delay = randf() * gutterFallMaxDelay
	_gutterTimer.start(delay)
	yield(_gutterTimer, "timeout")
	_startFalling()

func _setActive(active: bool):
	_isActive = active
	_activeSprite.visible = active
	_inactiveSprite.visible = !active
	_setCollidable(active)

func _canChangeColor() -> bool:
	return color != Types.ElementColor.GRAY
	
func _takeDamage(damage: int):
	if _health > 0:
		_health = max(_health - damage, 0)
		_playFlash(flashDuration)
		if _health == 0:
			if _manager:
				_manager.addScore(points)
			
			if fallAtZeroHealth:
				_startFalling()
			else:
				_onDestroyed()
			
func _onDestroyed():
	_setCollidable(false)
	_isDestroyed = true
	
func _playFlash(duration: float):
	if _isFlashing:
		return
	
	_isFlashing = true
	_flashSprite.self_modulate = flashColor
	_flashSprite.visible = true
	
	_flashTimer.start(duration)
	yield(_flashTimer, "timeout")
	
	_flashSprite.visible = false
	_isFlashing = false
	
func _setCollidable(collidable: bool):
	# never re-enable collision after being destroyed
	if _isDestroyed:
		collidable = false
	
	_collision.set_deferred("disabled", !collidable)
	
func _startFalling():
	if _isFalling:
		return
	
	# Do an initial jump when we start falling
	_fallSpeed = -fallJumpSpeed
	
	# Rotate ourselves slightly to indicate that we're falling
	var rotationOffset = rand_range(abs(fallMinAngleOffset), abs(fallMaxAngleOffset))
	if randf() > .5:
		rotationOffset *= -1
	rotation += deg2rad(rotationOffset)
	
	# Disable standard collision
	_setCollidable(false)
	
	# remove ourselves from our group and add ourselves directly to the brick container
	_isReparenting = true
	var globalPosition = global_position
	get_parent().remove_child(self)
	_manager.brickContainer.add_child(self)
	_isReparenting = false
	global_position = globalPosition
	
	# Enable our damage area
	_fallingArea.monitoring = true
	
	# Play our SFX
	_fallSFX.play()
	
	_isFalling = true
	pass
	
func _updateFalling(delta: float):
	_fallSpeed = min(maxFallSpeed, _fallSpeed + fallAcceleration * delta)
	var offset = Vector2.DOWN * _fallSpeed * delta
	position = position + offset
	
func _on_FallingArea_body_entered(body):
	if !_isActive:
		return
	
	if body.has_method("onFallingBrickHit"):
		body.onFallingBrickHit(self)


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	if !_isReparenting:
		queue_free()


func _on_GutterDetectionArea_area_entered(area):
	if area.is_in_group("Gutter"):
		onGutterEntered()
