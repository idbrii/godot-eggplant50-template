extends Control

var current_shape = 'Triangle'

func on_seed_change(shape):
	get_node('%s/Highlight' % current_shape).visible = false
	get_node('%s/Highlight' % shape.status_name()).visible = true
	current_shape = shape.status_name()
