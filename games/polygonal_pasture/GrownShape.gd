class_name GrownShape

extends RigidBody2D

signal shapes_merged(shape_a, shape_b)

# Maybe all better as a Resource?
enum ShapeName { TRIANGLE, SQUARE, RHOMBUS }
export(ShapeName) var shape_name

enum ShapeSize { SMALL, MEDIUM, LARGE }
export(ShapeSize) var shape_size

export(ShapeName) var merge_with_name
export(ShapeSize) var merge_with_size
export var merge_result : PackedScene

func _ready() -> void:
	connect('body_entered', self, '_on_shape_touch')
#	connect('body_exited', self, '_on_shape_untouch')

func _on_shape_touch(body):
	# This sure is ugly!
	if body.get('merge_with_name') == null:
		return
	if merge_with_name == body.merge_with_name and merge_with_size < body.merge_with_size:
		wait_on_merger(body)

func wait_on_merger(other_shape):
	yield(get_tree().create_timer(0.5), "timeout")
	if get_colliding_bodies().has(other_shape):
		emit_signal('shapes_merged', self, other_shape)
