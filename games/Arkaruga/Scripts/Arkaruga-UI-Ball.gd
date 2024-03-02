extends TextureRect

const Types = preload("res://games/Arkaruga/Scripts/Arkaruga-Types.gd")

export var textureBlue : Texture
export var textureGreen : Texture

onready var _manager : Node2D = get_tree().get_nodes_in_group("Manager")[0]

func _ready():
	if _manager:
		onActiveColorChanged(_manager.activeColor)
	
func onActiveColorChanged(color: int):
	_setColor(color)
	
func _setColor(color: int):
	match color:
		Types.ElementColor.BLUE:
			texture = textureBlue
		Types.ElementColor.GREEN:
			texture = textureGreen
