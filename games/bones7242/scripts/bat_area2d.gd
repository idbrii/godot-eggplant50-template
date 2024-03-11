extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var start_x = 200
var start_y = 140

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(start_x,start_y)
	visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	
	draw_rect(Rect2(0, 0, 50, 30), Color("#39855a"), false)
	pass
