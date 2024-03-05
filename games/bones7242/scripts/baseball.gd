extends Area2D

var angular_speed = PI
var starting_windup_speed = 10
var windup_speed = starting_windup_speed
var max_windup_speed = 200

const State = {HELD = 0, WINDUP = 1, RELEASED = 2, GROUNDED = 3}
# Access values with State.HELD, etc.

var initial_state = State.HELD
var current_state : int
var last_state : int
# tbd: set up with enter and exit state functions to set state.

var y_power = 0
var power_increment = 40
var grav = power_increment
var max_fall_speed = 100

var h_move_speed = 8

func change_state(new_state):
	# store the current state as last state, if it exists
	if current_state:
		last_state = current_state
	
	current_state = new_state
	
	pass

func _ready():
	change_state(initial_state)
	pass
	
func _process(delta):
	# rotation += angular_speed * delta
	#position +=  Vector2.DOWN * movement_speed * delta
	
	match current_state:
		State.HELD:
			position.y = 100
		State.WINDUP:
			position.y = 200
		State.RELEASED:
			# do released stuff
			y_power -= grav
			#print('power:' + str(power))
			var next_movement = -1 * y_power * delta
			if next_movement <= max_fall_speed:
				position.y += next_movement # move ball the ball
			# also listen for hitting the ground
			if position.y >= 300:
				change_state(State.GROUNDED)
				y_power = 0 #reset power
		State.GROUNDED:
			position.y = 300
		_:
			print("I am not a baseball state I know of!")
		
	#print('power:' + str(power))
