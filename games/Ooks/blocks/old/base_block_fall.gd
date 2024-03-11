extends KinematicBody2D


var normal_fall_speed = 100.0
var fall_speed = 100.0
var my_velocity
var sent_stopped = false
var time = 0.0
var wait_time = 0.1 #need to wait a bit before allowing to send to parent that they've stopped. i guess because when spawned in, because of neighbors colliding, it may have 0 speed for a bit before the whole block starts moving.

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	time += delta
	my_velocity = move_and_slide(Vector2(0.0,fall_speed))
	if sent_stopped==false and fall_speed>0 and my_velocity == Vector2(0.0,0.0) and time>wait_time:
#		print("stopped!")
		sent_stopped = true
		if get_parent().has_method("child_sending_stopped"):
			get_parent().child_sending_stopped()



func parent_set_falling(falling):
	if falling:
		fall_speed = normal_fall_speed
	else:
		fall_speed = 0

