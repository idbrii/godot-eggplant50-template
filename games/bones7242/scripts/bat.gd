extends Node2D

const State = {IDLE = 0, WINDUP = 1, SWING = 2, FOLLOWTHROUGH = 3}
# Access values with State.HELD, etc.


var starting_windup_speed = 10
var windup_speed = starting_windup_speed
var max_windup_speed = 100
var initial_power = 0
var power = initial_power
var power_increment = 1
var max_power = 100

# variables for swinging
var bat_x = 640 / 2
var bat_y = 320 / 2
var start_swing_x = 0
var swing_x = start_swing_x
var max_swing_x = 300
var start_swing_y = 0
var swing_y = start_swing_y
var max_swing_y = 100
var bat_start_radius = 64
var bat_radius = bat_start_radius
var min_bat_radius = 16
const RED = Color(1,0,0)
const GREEN = Color( 0, 1, 0, 1 )
var color = GREEN
var swing_center : Vector2

var initial_state = State.IDLE
var current_state : int
var last_state : int

var swing_x_swing_increment : int
var swing_y_swing_increment : int
var bat_radius_increment : int

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
	
	match current_state:
		State.IDLE:
			#print("i am HELD")
			#wait around
			#listen for change to windup
			if Input.is_action_pressed("action2"):
				change_state(State.WINDUP)
				print("i am winding up the bat")
		State.WINDUP:
			# do windup stuff
			#make circle bigger
			bat_radius -= (bat_radius - min_bat_radius) / 10
			#change x and y to pull circle back on an arc
			swing_x += (max_swing_x - swing_x) / 30
			swing_y += (max_swing_y - swing_y) / 30
			print('winding up bat:' + str(bat_radius))
			# build up power
			if power < max_power:
				power += power_increment
			#listen for change to released
			if Input.is_action_just_released("action2"):
				print("i am SWING the bat")
				print('swing power:' + str(power))
				change_state(State.SWING)
				# set vars for swing
				#var speed = 110 - power
				swing_x_swing_increment = (swing_x - start_swing_x) / 5
				swing_y_swing_increment = (swing_y - start_swing_y) / 5
		State.SWING:
			# do swing stuff
			#bat_radius -= bat_radius_increment
			swing_x -= swing_x_swing_increment
			swing_y -= swing_y_swing_increment
			# listen for swing complete
			if swing_x <= start_swing_x:
				change_state(State.FOLLOWTHROUGH) #should go to follow through.
				color = RED
		State.FOLLOWTHROUGH:
			# tbd: move ball up and left, hold for a moment
			# when done, go back to idle
			if swing_x < max_swing_x:
				swing_x += swing_x_swing_increment
				swing_y += swing_y_swing_increment

			if Input.is_action_just_released("action2"):
				change_state(State.IDLE)
				color = GREEN
				#reset vars
				swing_x = start_swing_x
				swing_y = start_swing_y
				bat_radius = bat_start_radius
		_:
			print("I am not a bat state I know of!")
		
	#print('power:' + str(power))
	update()

func _draw():
	#draw bat circle
	swing_center = Vector2(bat_x - swing_x, bat_y - swing_y)
	print('swing_center draw:' + str(swing_center))
	draw_circle(swing_center, bat_radius, color)
