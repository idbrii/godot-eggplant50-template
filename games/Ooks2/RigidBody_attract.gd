extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var other
var forcing = false
var locked = false
#var transitioning = false
var ext_applying_force = Vector2(0,0)
var force_amount = 15
var move
#onready var global_pos = get_parent().position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(_delta):
	if other != null:
#		if transitioning:
#
		if forcing:
			$CollisionShape2D.disabled = true
			gravity_scale = 0
			
			var temp_force = Vector2(0,0)
			var temp_distance = other.get_global_transform().origin-self.get_global_transform().origin
			#temp_force = temp_force.limit_length(5) #does nothing helpful. need to check if length is too far and stop it manually somehow.
			if temp_distance.length_squared() > 1000:
				temp_force = temp_distance*0.1 + ext_applying_force*0.2
			else:
				temp_force = ext_applying_force
			if linear_velocity.length_squared() > 10000:
				temp_force = -1*linear_velocity*0.5
			apply_central_impulse(temp_force)
		else:
			$CollisionShape2D.disabled = false
			gravity_scale = 1
			if linear_velocity.y < 0:
				gravity_scale = 10
			
			apply_central_impulse(Vector2((other.get_global_transform().origin.x-self.get_global_transform().origin.x)*0.015,0))
	else:
		print("other is null")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
#	if Input.is_action_just_pressed("move_right"):
#		ext_applying_force.x += force_amount
#	elif Input.is_action_just_released("move_right"):
#		ext_applying_force.x -= force_amount
#	if Input.is_action_just_pressed("move_left"):
#		ext_applying_force.x -= force_amount
#	elif Input.is_action_just_released("move_left"):
#		ext_applying_force.x += force_amount
#	if Input.is_action_just_pressed("move_up"):
#		ext_applying_force.y -= force_amount
#	elif Input.is_action_just_released("move_up"):
#		ext_applying_force.y += force_amount
#	if Input.is_action_just_pressed("move_down"):
#		ext_applying_force.y += force_amount
#	elif Input.is_action_just_released("move_down"):
#		ext_applying_force.y -= force_amount
	
	move = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	ext_applying_force = move*force_amount
#	print(move)
	
