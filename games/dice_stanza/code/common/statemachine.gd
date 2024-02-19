#~ class_name StateMachine
extends Node


signal state_transition(new_state) # passes the state table


const label_scene = preload("res://games/dice_stanza/scenes/ui_statemachine_label.tscn")



var states
var current_state


func add_label(parent) -> Control:
	var label = label_scene.instance()
	var display = label.get_node("Label")
	display.target = self
	parent.add_child(label)
	return label


# Define states as nodes:
#   onready var states = {
#   	default_state = $StateMachine/Default,
#   	freestyle = $StateMachine/Freestyle,
#   	climb = $StateMachine/Climb,
#   }
func create_states(all_states) -> void:
	states = all_states
	current_state = all_states.default_state


func current():
	return current_state


func transition_to(dest, data):
	current_state.exit(data)
	current_state = dest
	dest.enter(data)
	emit_signal("state_transition", dest)


# Get a string name for the input state. Use sm.find_state_name(sm.current())
# to get the current state name.
func find_state_name(state) -> String:
	for key in states:
		if states[key] == state:
			return key
	return "<unknown>"

# call from _process or _physics_process.
func tick(dt):
	current_state.update(dt)


