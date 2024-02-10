extends Node

var states : Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child

func _process(delta):
	if current_state:
		current_state.Update(delta)
	
func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)
