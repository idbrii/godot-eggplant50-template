extends Node2D
export(PackedScene) var BatScene
export(Vector2) var screen_size
export(int) var move_size

var bat

func _process(_delta):
	handle_bat_move()
	handle_bat_action()

func handle_bat_move():
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

func handle_bat_action():
	if Input.is_action_just_released("action1"):
		var intersecting_bodies = bat.get_node('Area2D').get_overlapping_bodies()
		print('colliding: ', intersecting_bodies)

# Called when the node enters the scene tree for the first time.
func _ready():
	bat = BatScene.instance()
	bat.position = Vector2(32, 32)
	self.add_child(bat)
