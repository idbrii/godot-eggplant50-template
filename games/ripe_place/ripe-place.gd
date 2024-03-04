extends Node2D
export(PackedScene) var BatScene
export(Vector2) var screen_size
export(int) var move_size
 
var bat

func _process(_delta):
	var x = 0
	var y = 0
	if Input.is_action_just_released("move_left"):
		x -= 1
	if Input.is_action_just_released("move_right"):
		x += 1
	if Input.is_action_just_released("move_up"):
		y -= 1
	if Input.is_action_just_released("move_down"):
		y += 1
	
	var move = Vector2(x * move_size, y * move_size)
		
	bat.position += move
	bat.position.x = clamp(bat.position.x, 0, screen_size.x)
	bat.position.y = clamp(bat.position.y, 0, screen_size.y)
#	# Using get_axis will have a cross deadzone.
#	var move_x := Input.get_axis("move_left", "move_right")
#	var move_y := Input.get_axis("move_up", "move_down")

# Called when the node enters the scene tree for the first time.
func _ready():
	bat = BatScene.instance()
	bat.position = Vector2(32, 32)
	self.add_child(bat)
