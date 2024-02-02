class_name GrownShape

extends RigidBody2D

const PpShape = preload('res://games/polygonal_pasture/Shape.gd')

signal shapes_merged(shape_a, shape_b)

var shape : PpShape

export(PpShape.ShapeName) var merge_with_name
export(PpShape.ShapeSize) var merge_with_size

var merge_wait : Timer

func _ready() -> void:
	merge_wait = Timer.new()
	add_child(merge_wait)
	merge_wait.one_shot = true
	merge_wait.wait_time = 9.0
	merge_wait.start()
	merge_wait.connect('timeout', self, 'merge_wait_over')
	
	connect('body_entered', self, '_on_shape_touch')
#	connect('body_exited', self, '_on_shape_untouch')

func _on_shape_touch(body):
	if body is StaticBody2D:
		return
	if merge_with_name == body.merge_with_name \
	and shape.shape_size == body.merge_with_size \
	and merge_with_size < body.merge_with_size:
		wait_on_merger(body)

func wait_on_merger(other_shape):
	merge_wait.paused = true
	yield(get_tree().create_timer(0.5), "timeout")
	if get_colliding_bodies().has(other_shape):
		emit_signal('shapes_merged', self, other_shape)
		collision_layer = 2
		collision_mask = 2
		add_central_force(Vector2(0, 100))
	else:
		merge_wait.paused = false

func merge_wait_over():
	# TODO Animation etc
	collision_layer = 2
	collision_mask = 2
	add_central_force(Vector2(0, 200))
