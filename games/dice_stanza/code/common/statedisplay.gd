extends Label

const Validate = preload("res://games/dice_stanza/code/util/validate.gd")


export var target_node : NodePath

onready var _target := get_node_or_null(target_node)


func _ready():
	Validate.ok(_target.connect("state_transition", self, "_on_state_transition"))

func _on_state_transition(new_state):
	var state_label = _target.find_state_name(new_state)
	set_text(state_label)

