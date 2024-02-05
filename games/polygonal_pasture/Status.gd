extends Control

var current_shape = 'Triangle'
var total_score = 0
var mergers = 0

func on_seed_change(shape):
	get_node('%s/Highlight' % current_shape).visible = false
	get_node('%s/Highlight' % shape.status_name()).visible = true
	current_shape = shape.status_name()

func on_score_update(shape):
	total_score += shape.final_score()
	$Score/Value.text = str(total_score)
	mergers += shape.from_merger
	$Mergers/Value.text = str(mergers)
