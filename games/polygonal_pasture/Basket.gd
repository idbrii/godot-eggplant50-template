extends Node2D

signal shape_ready_to_collect(shape)

const PpShape = preload('res://games/polygonal_pasture/Shape.gd')

var triangle_small  = preload('res://games/polygonal_pasture/shapes/TriangleSmall.tscn')
var triangle_medium = preload('res://games/polygonal_pasture/shapes/TriangleMedium.tscn')
var triangle_large  = preload('res://games/polygonal_pasture/shapes/TriangleLarge.tscn')

var square_small  = preload('res://games/polygonal_pasture/shapes/SquareSmall.tscn')
var square_medium = preload('res://games/polygonal_pasture/shapes/SquareMedium.tscn')
var square_large  = preload('res://games/polygonal_pasture/shapes/SquareLarge.tscn')


var shape_map = [null, null, null]

func _ready() -> void:
	var tmap = [null, null, null]
	tmap.insert(PpShape.ShapeSize.SMALL, triangle_small)
	tmap.insert(PpShape.ShapeSize.MEDIUM, triangle_medium)
	tmap.insert(PpShape.ShapeSize.LARGE, triangle_large)
	shape_map.insert(PpShape.ShapeName.TRIANGLE, tmap)
	var smap = [null, null, null]
	smap.insert(PpShape.ShapeSize.SMALL, square_small)
	smap.insert(PpShape.ShapeSize.MEDIUM, square_medium)
	smap.insert(PpShape.ShapeSize.LARGE, square_large)
	shape_map.insert(PpShape.ShapeName.SQUARE, smap)
	
func on_shape_gathered(shape):
	var shape_node : GrownShape = shape_map[shape.shape_name][shape.shape_size].instance()
	shape_node.shape = shape.duplicate() # Maybe just assign shape_{name,size}???
	shape_node.position = Vector2(425+(randi()%180), - 64)
	shape_node.rotation_degrees = randi() % 360
	shape_node.mode = RigidBody2D.MODE_RIGID
	shape_node.connect('shapes_merged', self, '_on_shape_merger')
	shape_node.connect('shape_collectable', self, '_on_shape_collectable')
	shape_node.contact_monitor = true
	shape_node.contacts_reported = 10
	add_child(shape_node)

func _on_shape_merger(shape_a: GrownShape, shape_b: GrownShape):
	var shape = PpShape.new()
	shape.shape_name = shape_a.merge_to_name
	shape.shape_size = shape_a.merge_to_size

	var new_shape : GrownShape = shape_map[shape.shape_name][shape.shape_size].instance()
	add_child(new_shape)

	# Wait for the shape node to be initialized.
	yield(get_tree(), "idle_frame")
	new_shape.shape = shape
	new_shape.from_merger = (shape_a.from_merger+shape_b.from_merger)+1
	new_shape.position = shape_a.position
	new_shape.rotation = shape_a.rotation
	new_shape.mode = RigidBody2D.MODE_RIGID
	new_shape.connect('shapes_merged', self, '_on_shape_merger')
	new_shape.connect('shape_collectable', self, '_on_shape_collectable')
	new_shape.contact_monitor = true
	new_shape.contacts_reported = 10

	remove_child(shape_a)
	remove_child(shape_b)

func _on_shape_collectable(shape):
	emit_signal('shape_ready_to_collect', shape)
