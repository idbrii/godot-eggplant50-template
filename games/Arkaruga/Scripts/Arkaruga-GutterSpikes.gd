extends TextureRect

export var _speed = 16.0
	
func _process(delta):
	rect_position.x += _speed * delta
	if rect_position.x > get_viewport_rect().size.x:
		rect_position.x = -rect_size.x

