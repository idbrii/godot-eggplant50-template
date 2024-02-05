class_name PpShape
extends Sprite

enum ShapeName { TRIANGLE, SQUARE, RHOMBUS }
export(ShapeName) var shape_name

enum ShapeSize { SEED, SMALL, MEDIUM, LARGE, ROTTEN }
export(ShapeSize) var shape_size

const texture_path_format = 'res://games/polygonal_pasture/assets/%s-%s.png'

const name_map = [null, null]
const size_map = [null, null, null, null, null, null]

func _init():
	name_map.insert(ShapeName.TRIANGLE, 'triangle')
	name_map.insert(ShapeName.SQUARE, 'square')

	size_map.insert(ShapeSize.SEED, 'seed')
	size_map.insert(ShapeSize.SMALL, 'small')
	size_map.insert(ShapeSize.MEDIUM, 'medium')
	size_map.insert(ShapeSize.LARGE, 'large')
	size_map.insert(ShapeSize.ROTTEN, 'rotten')

func texture_path():
	return texture_path_format % [name_map[shape_name], size_map[shape_size]]

func status_name():
	return name_map[shape_name].capitalize()
