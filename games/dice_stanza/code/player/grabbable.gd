#~ class_name Grabbable
extends Area2D


const Validate = preload("res://games/dice_stanza/code/util/validate.gd")


export var owner_node : NodePath
onready var _owner = get_node(owner_node)

func _ready():
	Validate.ok(self.connect("body_entered", self, "_on_body_entered"))
	Validate.ok(self.connect("body_exited", self, "_on_body_exited"))


func _on_body_entered(body):
	if body.is_in_group("Grabber"):
		body.call_deferred("set_grab_target", _owner)


func _on_body_exited(body):
	if body.is_in_group("Grabber"):
		body.call_deferred("clear_grab_target", _owner)
