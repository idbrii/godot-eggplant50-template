extends Sprite

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

var power = 0
var power_increment = 40
var gravity = power_increment
var max_fall_speed = 100

var h_move_speed = 8

# variables for swinging
var bat_x = 640 / 2
var bat_y = 320 / 2
var start_swing_x = 0
var swing_x = start_swing_x
var start_swing_y = 0
var swing_y = start_swing_y
var bat_start_radius = 32
var bat_radius = bat_start_radius
var color = Color(1,0,0)
const GREEN = Color( 0, 1, 0, 1 )
var swing_center : Vector2

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
			#print("i am HELD")
			#wait around
			# movement
			var move_x := Input.get_axis("move_left", "move_right")
			position.x += move_x * h_move_speed
			#listen for change to windup
			if Input.is_action_pressed("action1"):
				change_state(State.WINDUP)
				print("i am winding up")
		State.WINDUP:
			#print("i am WINDUP")
			# do windup stuff
			var potential_move = 1 * windup_speed * delta
			if (position.y + potential_move) < 300:
				position.y += potential_move
				power += power_increment
				print('power:' + str(power))
				windup_speed += (max_windup_speed - windup_speed) / 2 #tweening to max
			#listen for change to released
			if Input.is_action_just_released("action1"):
				print("i am RELEASED")
				change_state(State.RELEASED)
				windup_speed = starting_windup_speed #reset windup speed
		State.RELEASED:
			#print("i am RELEASED")
			# do released stuff
			power -= gravity
			#print('power:' + str(power))
			var next_movement = -1 * power * delta
			if next_movement <= max_fall_speed:
				position.y += next_movement # move ball the ball
			
			# listen for swing
			# draw circle
			var windup = Input.is_action_pressed("action1")
			var swing = Input.is_action_just_released("action1")
			
			if windup:
				#make circle bigger
				bat_radius += 2
				#pull circle back on an arc
				swing_x += 10
				swing_y += 5
				print('winding up bat:' + str(bat_radius))
			
			if swing:
				print('SWING!' + str(bat_radius))
				#reset vars
				bat_radius = bat_start_radius
				swing_x = start_swing_x
				swing_y = start_swing_y
			
			#draw circle
			swing_center = Vector2(bat_x - swing_x, bat_y - swing_y)
			#print('swing_center:' + str(swing_center))
			
			# also listen for hitting the ground
			if position.y >= 300:
				change_state(State.GROUNDED)
				power = 0 #reset power
		State.GROUNDED:
			#print("i am GROUNDED")
			if Input.is_action_just_released("action1"):
				change_state(State.HELD)
				position.y = 199
		_:
			print("I am not a state I know of!")
		
	#print('power:' + str(power))

func _draw():
	#test
	draw_circle(Vector2(120,120), 10, GREEN)
	#draw bat circle
	print('swing_center draw:' + str(swing_center))
	draw_circle(swing_center, bat_radius, color)
