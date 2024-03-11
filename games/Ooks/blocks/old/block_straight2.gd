extends Node2D



var is_active = true
var rotate_deg_left = 0
var rotating = false
var rotation_speed = 5 #1,2,3,5
#var fall_vector = Vector2(0.0,50.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(_delta):
	if is_active:
		if Input.is_action_just_pressed("action1"):
			if rotating == false:
				update_child_fall(false)
				rotating = true
				rotate_deg_left = 90
		if rotating:
			process_rotate()
	#		print('rotate')

func send_player_hit():
#	print("straight hit by player")
	pass

func process_rotate():
	rotation_degrees += rotation_speed
	rotate_deg_left -= rotation_speed
	if rotate_deg_left == 0:
		rotating = false
		if true: #is_active:
			update_child_fall(true)

func update_child_fall(falling):
	for child in get_children():
		if child.has_method("parent_set_falling"):
			child.parent_set_falling(falling)

func child_sending_stopped():
	if is_active:
		is_active = false
		if get_parent().has_method("child_sending_next"):
			get_parent().child_sending_next()
	
