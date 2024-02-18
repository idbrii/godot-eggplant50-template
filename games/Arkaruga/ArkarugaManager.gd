extends Node2D

const Types = preload("res://games/Arkaruga/Scripts/Arkaruga-Types.gd")

var _activeColor = Types.ElementColor.BLUE

func _ready():
	setActiveColor(Types.ElementColor.GREEN)
	
func _input(event):
	if event.is_action_pressed("action1"):
		swapActiveColor()

func swapActiveColor():
	match _activeColor:
		Types.ElementColor.BLUE:
			setActiveColor(Types.ElementColor.GREEN)
		Types.ElementColor.GREEN:
			setActiveColor(Types.ElementColor.BLUE)

func setActiveColor(color: int):
	_activeColor = color
	get_tree().call_group("Colorized", "onActiveColorChanged", color)
