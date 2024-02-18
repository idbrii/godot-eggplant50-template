extends KinematicBody2D

const Types = preload("res://games/Arkaruga/Scripts/Arkaruga-Types.gd")

export(Types.ElementColor) var color = Types.ElementColor.BLUE

onready var _activeSprite : Sprite = $ActiveSprite
onready var _inactiveSprite : Sprite = $InactiveSprite
onready var _collision : CollisionShape2D = $Collision

func _ready():
	# PROBABLY NEEDS TO GRAB THE CURRENT COLOR FROM THE MANAGER
	pass
	
func onActiveColorChanged(color: int):
	if _canChangeColor():
		_setActive(color == self.color)
		
func _setActive(active: bool):
	_activeSprite.visible = active
	_inactiveSprite.visible = !active
	_collision.set_deferred("disabled", !active)
	
func _canChangeColor() -> bool:
	return color != Types.ElementColor.GRAY
