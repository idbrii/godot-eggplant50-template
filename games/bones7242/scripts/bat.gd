extends Node2D 

const State = {
	STAND = 0,
	CROUCH = 1, 
	RELEASE = 2, 
	WINDUP = 3,
	SWING = 4,
	FOLLOWTHROUGH = 5
	}
# Access values with State.HELD, etc.

var start_throw_power = 0
var throw_power = start_throw_power
var max_throw_power = 100
var start_swing_power = 0
var swing_power = start_swing_power
var max_swing_power = 100
var power_increment = 1

var initial_state = State.STAND
var current_state : int
var last_state : int
var batter_sprite : Sprite

func change_state(new_state):
	# store the current state as last state, if it exists
	if current_state:
		last_state = current_state
	
	current_state = new_state
	pass

func check_for_hit():
	#get position of ball
	var baseball_object = $"../baseball_area2d"
	#see if ball within radius of hitting sphere
	var distance_to_ball_center = position.distance_to(baseball_object.position)
	print('distance to ball = ' + str(distance_to_ball_center))
	return distance_to_ball_center < 100

func _ready():
	change_state(initial_state)
	batter_sprite = get_node("Sprite")
	batter_sprite.texture = load("res://games/bones7242/sprites/batter-test-05.png") # set initial sprite
	pass
	
func _process(delta):
	
	match current_state:
		State.STAND:
			#listen for input
			if Input.is_action_pressed("action1"):
				print("batter is crouching")
				# change to next state
				change_state(State.CROUCH)
				batter_sprite.texture = load("res://games/bones7242/sprites/batter-test-06.png")
				# tBD: change sprite
		State.CROUCH:
			# Build up power
			if throw_power < max_throw_power:
					throw_power += power_increment
			# listen for input
			if Input.is_action_just_released("action1"):
				print("batter is releasing")
				# change to next state
				change_state(State.RELEASE)
				# tBD: change sprite
				batter_sprite.texture = load("res://games/bones7242/sprites/batter-test-07.png")
				# TBD: apply power to the ball and relase it
				throw_power = start_throw_power
		State.RELEASE:
			#TBD: pause for a second?
			if Input.is_action_pressed("action1"):
				print("batter is winding up")
				# change to next state
				change_state(State.WINDUP)
				batter_sprite.texture = load("res://games/bones7242/sprites/batter-test-02.png")
		State.WINDUP:
			# build up power
			if swing_power < max_swing_power:
				swing_power += power_increment
			#listen for change to released
			if Input.is_action_just_released("action1"):
				print("i am SWING the bat")
				print('swing power:' + str(swing_power))
				change_state(State.SWING)
				batter_sprite.texture = load("res://games/bones7242/sprites/batter-test-03.png")
		State.SWING:
			# if so, then initiate the hit state on baseball
			if check_for_hit():
				print("YOU GOT A HIT!")
				#TBD: add velocity to ball for hit
			change_state(State.FOLLOWTHROUGH) #should go to follow through.
			batter_sprite.texture = load("res://games/bones7242/sprites/batter-test-04.png")
			swing_power = start_swing_power # reset swing power
		State.FOLLOWTHROUGH:
			#if Input.is_action_just_released("action2"):
			if true: #placeholder - replace with timer after ball hits ground.
				change_state(State.STAND)
				batter_sprite.texture = load("res://games/bones7242/sprites/batter-test-05.png")
		_:
			print("I am not a bat state I know of!")
		
	#print('power:' + str(power))
	update()

#func _draw():
#	draw_circle(swing_center, bat_radius, color)
