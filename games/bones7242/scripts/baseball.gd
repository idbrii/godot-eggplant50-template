extends Area2D

const State = {HELD = 0, WINDUP = 1, RELEASED = 2, GROUNDED = 3}
# Access values with State.HELD, etc.

var room_height = 360 #TO do replace with actual propery
var room_width = 640 #TO do replace with actual propery

var initial_state = State.HELD
var current_state : int
var last_state : int
# tbd: set up with enter and exit state functions to set state.

var power = 0
var grav = 10
var max_fall_speed = 100

var unprojectedX = 260
var unprojectedY = 300 # should start up off the ground a bit
var unprojectedZ = 2
var xVelocity = 0 # will be set by creator
var yVelocity = 0 # will be set by creator
var zVelocity = 0 # will be set by creator
var yGravity = 0 # set by creator, should be set globally so all have same gravity

var projectedCoordinates : Array
var rotationSpeed = 5; # must be multiple of rotateUprightSpeed and 

func change_state(new_state):
	# store the current state as last state, if it exists
	if current_state:
		last_state = current_state
	
	current_state = new_state
	
	pass
	
func change_state_held():
	last_state = current_state
	change_state(State.HELD)
	#get_node("spr_baseball").visible = false
	pass

func change_state_released():
	last_state = current_state
	change_state(State.RELEASED)
	#get_node("spr_baseball").visible = true
	pass	

func change_state_grounded():
	last_state = current_state
	change_state(State.GROUNDED)
	power = 0 #reset power
	pass
	
func determineZAsPercent (unprojectedZDistance) :
	var unprojectedZasPerecentOfRoomHeight = 100 * unprojectedZDistance / (25 + unprojectedZDistance)
	var zDistanceAsPercent = unprojectedZasPerecentOfRoomHeight / 100
	return  zDistanceAsPercent
	
func convert3dCoordintesTo2d(x_cord, y_cord, z_cord):
	var projectedX : int
	var projectedY : int 
	
	var tX = unprojectedX # in room top left is 0,0, so tx = mouse_x
	var tY = unprojectedY 
	var tZ = unprojectedZ # in room top left is 0,0, so ty = room height - mouse_y
	var t = [tX, tY, tZ]

	# determine size of projected space (trapezoid)
	var desiredHorizonWidth = 520
	var desiredHorizonHeight = room_height - 32
	#desiredHorizonYLocation = 100;  // remember, top of screen is 0, bottom is room_height.
	var trTopLeft = [(room_width - desiredHorizonWidth)/2, desiredHorizonHeight]
	var trTopRight = [room_width - ((room_width - desiredHorizonWidth)/2), desiredHorizonHeight]
	var trBottomLeft = [0,0]
	var trBottomRight = [640,0]

	var HeightOfProjectedAtCenter = ((trTopLeft[1] - trBottomLeft[1]) + (trTopRight[1] - trBottomRight[1])) / 2
	#HeightOfProjectedLeft = tTopRight[1] - tBottomRight[1];  // 2d height squished field, currently still 360.
	#HeightOfProjectedRight = tTopRight[1] - tBottomRight[1]; // note: not used currently b/c no skewing or tilting
	var WidthOfProjectedFar = trTopRight[0] - trTopLeft[0]
	var WidthOfProjectedNear = trBottomRight[0] - trBottomLeft[0]
	var minimumDepth = 0
	var maximumDepth = HeightOfProjectedAtCenter


	# DETERMINE Y in 2D space
	var zDistanceAsPercent = determineZAsPercent(unprojectedZ)
	#projectedY = room_height - (room_height * zDistanceAsPercent) - unprojectedY;
	projectedY = room_height - (desiredHorizonHeight * zDistanceAsPercent) - unprojectedY;

	# DETERMINE X in 2D space
	# interpolate between two points representing two different widths at two different depths > [x (y value), y (width)] > [0,640] & [360, 520]
	var WidthAtProjectedDepth = WidthOfProjectedNear + ((t[2] - minimumDepth)/(maximumDepth-minimumDepth)*(WidthOfProjectedFar-WidthOfProjectedNear)) # interpolates between the bottom and top widths, linearly to find the width at the given height (z)
	var unusedSpaceLeftOfWidthAtDepth = (room_width - WidthAtProjectedDepth) / 2

	var XAsPercentOfOriginalWidth = t[0]/room_width
	var XPositionOnWidthAtDepth = XAsPercentOfOriginalWidth * WidthAtProjectedDepth

	projectedX = unusedSpaceLeftOfWidthAtDepth + XPositionOnWidthAtDepth;
	#clamp(x,0,room_width);// don't let x leave the screen left or screen right;
		
	return [projectedX, projectedY]
	
func set_3d_position():
	var projectedCoordinates = convert3dCoordintesTo2d(unprojectedX, unprojectedY, unprojectedZ)
	position.x = projectedCoordinates[0]
	position.y = projectedCoordinates[1]

func set_3d_position_from_coords (x_cord, y_cord, z_cord):
	# update the coords
	unprojectedX = x_cord
	unprojectedY = y_cord
	unprojectedZ = z_cord
	# update the 3d position
	set_3d_position()

func determineImageScale (zDistance) :
	var imageScale = determineZAsPercent(zDistance);
	return  imageScale;
		

func set_3d_image_scale () :
	scale = 

func _ready():
	change_state_held()
	set_3d_position()
	set_3d_image_scale()
	pass
	
func _process(delta):
	# rotation += angular_speed * delta
	#position +=  Vector2.DOWN * movement_speed * delta
	
	match current_state:
		State.HELD:
			pass
		State.RELEASED:
			# do released stuff
			power -= grav
			#print('power:' + str(power))
			var next_movement = -1 * power * delta
			if next_movement <= max_fall_speed:
				position.y += next_movement # move ball the ball
			# also listen for hitting the ground
			if position.y >= 300:
				change_state_grounded()
				power = min_power # reset
		State.GROUNDED:
			#if Input.is_action_just_released("action1"):
			if true: #placeholder - replace with timer after "strike" or hit or whatever.
				change_state_held()
		_:
			print("I am not a baseball state I know of!")
		
	#print('power:' + str(power))
