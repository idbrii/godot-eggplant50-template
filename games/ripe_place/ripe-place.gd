extends Node2D

export(PackedScene) var fruit_scene


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var fruit = fruit_scene.instance()
	fruit.position = Vector2(64, 64)
	add_child(fruit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
