extends KinematicBody2D

const Types = preload("res://games/Arkaruga/Scripts/Arkaruga-Types.gd")

export(Types.ElementColor) var color = Types.ElementColor.BLUE
export var maxHealth = 1
export var points = 1
export var _flashColor : Color = Color.white
export var _flashDuration : float = .25

onready var _activeSprite : Sprite = $ActiveSprite
onready var _inactiveSprite : Sprite = $InactiveSprite
onready var _flashSprite : Sprite = $FlashSprite
onready var _collision : CollisionShape2D = $Collision

onready var _health = maxHealth

var _isFlashing = false
var _isDestroyed = false

func _ready():
	_flashSprite.visible = false
	# PROBABLY NEEDS TO GRAB THE CURRENT COLOR FROM THE MANAGER
	pass
	
func _process(delta):
	if _isDestroyed and !_isFlashing:
		queue_free()
	
func onActiveColorChanged(color: int):
	if _canChangeColor():
		_setActive(color == self.color)
		
func onBallHit(ball):
	if _health > 0:
		_takeDamage(1)
		
func _setActive(active: bool):
	_activeSprite.visible = active
	_inactiveSprite.visible = !active
	_setCollidable(active)

func _canChangeColor() -> bool:
	return color != Types.ElementColor.GRAY
	
func _takeDamage(damage: int):
	if _health > 0:
		_health = max(_health - damage, 0)
		_playFlash(_flashDuration)
		if _health == 0:
			_onDestroyed()
			
func _onDestroyed():
	# TODO: Sometimes drop bricks instead of destroying them
	# TODO: Give points
	_setCollidable(false)
	_isDestroyed = true
	
func _playFlash(duration: float):
	if _isFlashing:
		return
	
	_isFlashing = true
	_flashSprite.self_modulate = _flashColor
	_flashSprite.visible = true
	yield(get_tree().create_timer(_flashDuration), "timeout")
	_isFlashing = false
	
func _setCollidable(collidable: bool):
	# never re-enable collision after being destroyed
	if _isDestroyed:
		collidable = false
	
	_collision.set_deferred("disabled", !collidable)
	

	
