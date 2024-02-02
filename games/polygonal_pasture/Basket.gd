extends Node2D

const PpShape = preload('res://games/polygonal_pasture/Shape.gd')

var triangle_small  = preload('res://games/polygonal_pasture/shapes/TriangleSmall.tscn')
var triangle_medium = preload('res://games/polygonal_pasture/shapes/TriangleMedium.tscn')
var triangle_large  = preload('res://games/polygonal_pasture/shapes/TriangleLarge.tscn')

var shape_map = [null, null, null]

func _ready() -> void:
	var tmap = [null, null, null]
	tmap.insert(PpShape.ShapeSize.SMALL, triangle_small)
	tmap.insert(PpShape.ShapeSize.MEDIUM, triangle_medium)
	tmap.insert(PpShape.ShapeSize.LARGE, triangle_large)
	shape_map.insert(PpShape.ShapeName.TRIANGLE, tmap)
	
func on_shape_gathered(shape):
	var shape_node : GrownShape = shape_map[shape.shape_name][shape.shape_size].instance()
	shape_node.shape = shape.duplicate() # Maybe just assigne shape_{name,size}???
	shape_node.position = Vector2(425+(randi()%180), - 64)
	shape_node.rotation_degrees = randi() % 360
	shape_node.mode = RigidBody2D.MODE_RIGID
	shape_node.connect('shapes_merged', self, '_on_shape_merger')
	shape_node.contact_monitor = true
	shape_node.contacts_reported = 10
	add_child(shape_node)

func _on_shape_merger(shape_a: RigidBody2D, shape_b: RigidBody2D):
	# TODO Spawn shape created from merger
	remove_child(shape_b)
