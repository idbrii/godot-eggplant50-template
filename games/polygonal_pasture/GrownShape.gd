class_name GrownShape

extends RigidBody2D

const PpShape = preload('res://games/polygonal_pasture/Shape.gd')

signal shapes_merged(shape_a, shape_b)
signal shape_collectable(shape)

export(PpShape.ShapeName) var merge_with_name
export(PpShape.ShapeSize) var merge_with_size

export(PpShape.ShapeName) var merge_to_name
export(PpShape.ShapeSize) var merge_to_size

export var score: int
export var merge_multiplier: int

var merge_wait : Timer
var flash_wait : Timer

var shape : PpShape
var has_merged = false
var is_merger = false
var maybe_merging = false
var from_merger = 0

func _ready() -> void:
	merge_wait = Timer.new()
	flash_wait = Timer.new()
	add_child(merge_wait)
	add_child(flash_wait)

	merge_wait.one_shot = true
	merge_wait.wait_time = 7.0
	merge_wait.start()
	merge_wait.connect('timeout', self, 'merge_wait_over')

	flash_wait.one_shot = true
	flash_wait.wait_time = 5.0
	flash_wait.start()
	flash_wait.connect('timeout', self, 'flash_wait_over')

	connect('body_entered', self, '_on_shape_touch')

func _on_shape_touch(body):
	if body.name == 'ScoreFloor':
		yield(get_tree(), "idle_frame")
		mode = RigidBody2D.MODE_STATIC
		$CollisionShape.disabled = true
		emit_signal('shape_collectable', self)
	elif !(body is StaticBody2D):
		if merge_with_name == body.shape.shape_name \
		and merge_with_size == body.shape.shape_size \
		and merge_with_size < body.merge_with_size:
			wait_on_merger(body)

func wait_on_merger(other_shape):
	merge_wait.paused = true
	maybe_merging = true
	yield(get_tree().create_timer(0.5), "timeout")
	if get_colliding_bodies().has(other_shape) and not has_merged:
		self.has_merged = true
		other_shape.has_merged = true
		emit_signal('shapes_merged', self, other_shape)
		collision_layer = 2
		collision_mask = 2
		add_central_force(Vector2(0, 100))
		modulate = Color('#ffffffff')
	else:
		merge_wait.paused = false
		maybe_merging = false

func merge_wait_over():
	# TODO Animation etc
	collision_layer = 2
	collision_mask = 2
	add_central_force(Vector2(0, 200))
	modulate = Color('#ffffffff')

func flash_wait_over():
	if maybe_merging or not is_inside_tree():
		return
	var fade_out = get_tree().create_tween()
	fade_out.tween_property(self, 'modulate', Color('#44ffffff'), 0.5)
	yield(fade_out, 'finished')

	if maybe_merging or not is_inside_tree():
		return
	var fade_in = get_tree().create_tween()
	fade_in.tween_property(self, 'modulate', Color('#ffffffff'), 0.5)
	yield(fade_in, 'finished')

	if maybe_merging or not is_inside_tree():
		return
	fade_out = get_tree().create_tween()
	fade_out.tween_property(self, 'modulate', Color('#44ffffff'), 0.5)
	yield(fade_out, 'finished')

	if maybe_merging or not is_inside_tree():
		return

	fade_in = get_tree().create_tween()
	fade_in.tween_property(self, 'modulate', Color('#ffffffff'), 0.5)
	yield(fade_in, 'finished')

func final_score() -> int:
	if from_merger > 0:
		return (score * merge_multiplier) * from_merger
	else:
		return score
