extends KinematicBody2D

var tetromino_type = 0
#block_straight=0 #straight down
#block_square=1 #follow
#block_Lr=2 #avoid
#block_Ll=3 #avoid
#block_k=4 #follow
#block_s=5 #zig-zag
#block_z=6 #zig-zag
var normal_fall_speed = 75.0
const fall_speed_multiplier = 3.0
const side_multiplier = 0.9
var fall_speed = normal_fall_speed
var zigzag_side_speed = 120
var side_speed = 0.0
var side_direction = 1 #for profile mode, zigzag resume after fast fall
var my_velocity
var sent_stopped = false
var is_rotatable = true
var rotating = false
var rotate_deg_left = 0
var rotation_speed = 5 #1,2,3,5
var rotation_direction = 1 #-1
var player
var challenge_mode = false
var random_mode = true
var profile_mode = false
onready var random = RandomNumberGenerator.new()
var rotate_timer_profile
var brown = preload("res://games/Ooks/blocks/brown.png")
var green = preload("res://games/Ooks/blocks/green.png")
var orange = preload("res://games/Ooks/blocks/orange.png")
var purple = preload("res://games/Ooks/blocks/purple.png")
var red = preload("res://games/Ooks/blocks/red.png")
var blue = preload("res://games/Ooks/blocks/blue.png")

# Called when the node enters the scene tree for the first time.
func _ready():
#	print(tetromino_type)
	player = get_tree().get_nodes_in_group("Player")[0]
	if tetromino_type == 1:
		var new = brown
		$Sprite.texture = new
		$Sprite2.texture = new
		$Sprite3.texture = new
		$Sprite4.texture = new
	elif tetromino_type == 2:
		var new = green
		$Sprite.texture = new
		$Sprite2.texture = new
		$Sprite3.texture = new
		$Sprite4.texture = new
	elif tetromino_type == 3:
		var new = orange
		$Sprite.texture = new
		$Sprite2.texture = new
		$Sprite3.texture = new
		$Sprite4.texture = new
	elif tetromino_type == 4:
		var new = purple
		$Sprite.texture = new
		$Sprite2.texture = new
		$Sprite3.texture = new
		$Sprite4.texture = new
	elif tetromino_type == 5:
		var new = red
		$Sprite.texture = new
		$Sprite2.texture = new
		$Sprite3.texture = new
		$Sprite4.texture = new
	elif tetromino_type == 6:
		var new = blue
		$Sprite.texture = new
		$Sprite2.texture = new
		$Sprite3.texture = new
		$Sprite4.texture = new
	if random_mode:
		random.randomize()
		side_speed = rand_range(-50,50)
		position.x += random.randi_range(-100,100)
		normal_fall_speed = 100
		fall_speed = normal_fall_speed
		if random.randi_range(0,1) == 1:
			rotating = true
			fall_speed = 0.0
			rotate_deg_left = 90
			#get_parent()._child_rototated(self.position)
	if profile_mode:
		rotate_timer_profile = Timer.new()
		rotate_timer_profile.wait_time = 1+tetromino_type*0.3
		rotate_timer_profile.connect("timeout",self,"_rotate_timer_timeout")
		add_child(rotate_timer_profile)
		rotate_timer_profile.start()
		if tetromino_type == 5 or tetromino_type == 6:
			side_speed = zigzag_side_speed
			if tetromino_type == 6:
				side_direction = -1
		elif tetromino_type == 0:
			position.x += random.randi_range(-135,135)


func _rotate_timer_timeout():
	if is_rotatable:
		rotating = true
		get_parent()._child_rototated(self.position)
		fall_speed = 0.0
		rotate_deg_left = 90
		if tetromino_type == 5 or tetromino_type == 6:
			side_direction *= -1


func _physics_process(_delta):
	if profile_mode and (tetromino_type == 5 or tetromino_type == 6):
		my_velocity = move_and_slide(Vector2(side_speed*side_direction,fall_speed))
	else:
		my_velocity = move_and_slide(Vector2(side_speed,fall_speed))
	if sent_stopped==false and fall_speed>0 and my_velocity.y == 0.0:
#		print("stopped!")
		sent_stopped = true
		is_rotatable = false
		if get_parent().has_method("child_sending_next"):
			get_parent().child_sending_next()
		get_parent()._child_fell(self.position)
	if is_rotatable:
		if challenge_mode:
			side_speed = (player.position.x-self.position.x)*side_multiplier
			if Input.is_action_just_pressed("action1"):
				if rotating == false:
					rotating = true
					get_parent()._child_rototated(self.position)
					fall_speed = 0.0
					rotate_deg_left = 90
		if profile_mode:
			if tetromino_type == 1 or tetromino_type == 4:
				side_speed = (player.position.x-self.position.x)*side_multiplier
			elif tetromino_type == 2 or tetromino_type == 3:
				side_speed = (player.position.x-self.position.x)*side_multiplier*-1
			#block_square=1 #follow
			#block_Lr=2 #avoid
			#block_Ll=3 #avoid
			#block_k=4 #follow
		if Input.is_action_pressed("move_down"):
			if not rotating:
				side_speed = 0.0
				fall_speed = fall_speed_multiplier*normal_fall_speed
		if Input.is_action_just_released("move_down"):
			if not rotating:
				fall_speed = normal_fall_speed
				if profile_mode and (tetromino_type == 5 or tetromino_type == 6):
					side_speed = zigzag_side_speed
#		if (self.position-player.position).x > 90:
#			side_speed = normal_side_speed*-1
#		elif (self.position-player.position).x < -90:
#			side_speed = normal_side_speed
#		else:
#			side_speed *= 0.99
		if rotating:
			process_rotate()
		else:
			if (self.position-player.position).x > 0:
				rotation_direction = 1
			else:
				rotation_direction = -1
	else:
		side_speed = 0


func process_rotate():
	rotation_degrees += rotation_speed*rotation_direction
	rotate_deg_left -= rotation_speed
	if rotate_deg_left == 0:
		rotating = false
		if true: #is_rotatable:
			fall_speed = normal_fall_speed


