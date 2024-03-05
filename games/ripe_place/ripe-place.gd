extends Node2D
export(PackedScene) var BatScene

var bat

# Called when the node enters the scene tree for the first time.
func _ready():
	bat = BatScene.instance()
	bat.position = Vector2(32, 32)
	self.add_child(bat)
