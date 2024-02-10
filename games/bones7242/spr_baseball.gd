extends Sprite

var angular_speed = PI
var starting_movement_speed = 200.00
var movement_speed = starting_movement_speed
var fall_speed = 300

var toss_up = false
var fall_down = false
var power = 0
var gravity = 0.5



func _process(delta):
	# rotation += angular_speed * delta
	#position +=  Vector2.DOWN * movement_speed * delta
	if Input.is_action_pressed("action1"):
		position +=  Vector2.DOWN * movement_speed * delta
		power += 1
	if Input.is_action_just_released("action1"):
		toss_up = true
		movement_speed = power * 100
	if toss_up == true:
		position +=  Vector2.UP * movement_speed * delta
		movement_speed = movement_speed * gravity
		if movement_speed <= 10:
			movement_speed = starting_movement_speed # reset speed
			toss_up = false
			fall_down = true
			power = 0 #reset power
	if fall_down == true:
		position +=  Vector2.DOWN * fall_speed * delta
		# check if hit ground.
		if position.y >= 300: 
			fall_down = false

	
