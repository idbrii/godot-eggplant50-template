extends Sprite

var angular_speed = PI
var starting_movement_speed = 20
var movement_speed = starting_movement_speed
#var max_gravity = 100
var fall_speed = 30

const State = {HELD = 0, WINDUP = 5, RELEASED = 6}
# Access values with State.HELD, etc.

var initial_state = State.HELD
var current_state : int
var last_state : int
# tbd: set up with enter and exit state functions to set state.

var power = 0
var gravity = 10

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
			print("i am HELD")
			#wait around
			#listen for change to windup
			if Input.is_action_pressed("action1"):
				change_state(State.WINDUP)
		State.WINDUP:
			print("i am WINDUP")
			# do windup stuff
			var potential_move = 1 * movement_speed * delta
			if (position.y + potential_move) < 300:
				position.y += potential_move
				power += 1
			#listen for change to released
			if Input.is_action_just_released("action1"):
				change_state(State.RELEASED)
				movement_speed = power
				power = 0
		State.RELEASED:
			print("i am RELEASED")
			# do released stuff
			movement_speed = movement_speed - gravity #apply gravity to potential movement
			position.y +=  -1 * movement_speed * delta # move ball the ball
			
			# listen for swing
			
			# also listen for hitting the ground
			if position.y >= 320:
				change_state(State.HELD)
				position.y = 199;
		_:
			print("I am not a state I know of!")
		
	print(str(movement_speed))

