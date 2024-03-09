#~ class_name NilRotation
extends Node


export(float, 0, 10) var max_delta := 0.0

export(NodePath) var target_path : NodePath
onready var target := get_node(target_path) as RigidBody2D



func _physics_process(_dt):
	target.global_rotation = clamp(target.global_rotation, -max_delta, max_delta)


