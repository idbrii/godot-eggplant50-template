extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var covered_fruit_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Area2D_body_entered(body):
	var entered_parent: Node2D = body.get_parent()
	print('entered: ', entered_parent)
	if entered_parent.get('is_a_fruit'):
		print('Bat is covering fruit ', entered_parent)
		var fruit_sprite: Sprite = entered_parent.get_node('Fruit/Sprite')
		fruit_sprite.set_scale(fruit_sprite.get_scale() * 2)

func _on_Area2D_body_exited(body):
	var exited_parent = body.get_parent()
	if exited_parent.get('is_a_fruit'):
		print('Bat is no longer over fruit ', exited_parent)
		var fruit_sprite: Sprite = exited_parent.get_node('Fruit/Sprite')
		fruit_sprite.set_scale(fruit_sprite.get_scale() / 2)
