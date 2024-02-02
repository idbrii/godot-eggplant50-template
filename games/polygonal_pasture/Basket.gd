extends Node2D

func on_shape_gathered(shape):
	var shape_node : RigidBody2D = $GrownShapes.get_node(shape).duplicate()
	shape_node.position = Vector2(425+(randi()%180), -64)
	shape_node.mode = RigidBody2D.MODE_RIGID
	add_child(shape_node)
