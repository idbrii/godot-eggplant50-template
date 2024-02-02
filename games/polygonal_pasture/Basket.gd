extends Node2D

func on_shape_gathered(shape):
	var shape_node : GrownShape = $GrownShapes.get_node(shape).duplicate()
	shape_node.position = Vector2(425+(randi()%180), - 64)
	shape_node.rotation_degrees = randi() % 360
	shape_node.mode = RigidBody2D.MODE_RIGID
	shape_node.connect('shapes_merged', self, '_on_shape_merger')
	shape_node.contact_monitor = true
	shape_node.contacts_reported = 10
	add_child(shape_node)

func _on_shape_merger(shape_a: GrownShape, shape_b: GrownShape):
	# TODO Spawn shape created from merger
	shape_a.collision_mask  = 2
	shape_a.collision_layer = 2
	remove_child(shape_b)
