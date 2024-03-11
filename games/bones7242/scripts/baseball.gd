extends Area2D

const State = {HELD = 0, RELEASED = 2, GROUNDED = 3}  # Access values with State.HELD, etc.
var delta_counter = 0

var room_height = 360 #TO do replace with actual propery
var room_width = 640 #TO do replace with actual propery
var ground = 0 # spot at which ball thinks its on ground.

var initial_state = State.HELD
var current_state : int
var last_state : int
# tbd: set up with enter and exit state functions to set state.

var unprojectedX = 0
var unprojectedY = 0 # should start up off the ground a bit
var unprojectedZ = 0
var xVelocity = 0 # will be set by creator
var yVelocity = 0 # will be set by creator
var zVelocity = 0 # will be set by creator
var minYVelocity = -1000
var yGravity = -20; # should just be set globally so all objects have same gravity.

var projectedCoordinates : Array
var rotationSpeed = 5; # must be multiple of rotateUprightSpeed and 

var homerun_distance = 100 # TBD: this shoudl really be stored elsewhere like score board

var shadow : Area2D

func change_state(new_state):
	# store the current state as last state, if it exists
	if current_state:
		last_state = current_state
	
	current_state = new_state
	
	delta_counter = 0 # reset for new state
	pass
	
func change_state_held():
	last_state = current_state
	change_state(State.HELD)
	unprojectedX = 220 # reset
	unprojectedY = 300 # reset
	unprojectedZ = 4 # reset
	xVelocity = 0 # reset
	yVelocity = 0 # reset
	zVelocity = 0 # reset
	get_node("spr_baseball").visible = false
	#get_parent().get_node("shadow_2d").visible = true
	pass

func change_state_released(batter_throw_power):
	yVelocity = batter_throw_power * 10 # multiplying b/c comes in 1-100 but now we will use delta
	print("RELEASED > y velocity = " + str(yVelocity))
	last_state = current_state
	change_state(State.RELEASED)
	get_node("spr_baseball").visible = true
	pass
	
func hit(batter_swing_power):
	if (State.RELEASED) :
		get_parent().get_node("AudioStreamPlayer2").play()
		yVelocity = batter_swing_power * 30 # multiplying b/c comes in 1-100 but now we will use delta
		zVelocity = batter_swing_power # make it a percent of max 20
		xVelocity = 10
	pass

func change_state_grounded():
	# do scoring
	if (unprojectedZ <= 4) :
		get_parent().get_node("Scoreboard").new_strike()
	elif (unprojectedZ >= (homerun_distance + 4)) :
		get_parent().get_node("Scoreboard").new_run()
	else :
		get_parent().get_node("Scoreboard").new_out()
	# change to grounded
	last_state = current_state
	change_state(State.GROUNDED)
	unprojectedY = ground  # set y to ground
	xVelocity = 0 # will be set by creator
	yVelocity = 0 # will be set by creator
	zVelocity = 0 # will be set by creator
	# reset batter's counter
	get_parent().get_node("batter_area2d").delta_counter = 0 
	get_parent().get_node("AudioStreamPlayer").play()
	#get_parent().get_node("shadow_2d").visible = false
	pass
	
func determineZAsPercent (unprojectedZDistance) :
	var unprojectedZasPerecentOfRoomHeight = 100 * float(unprojectedZDistance) / (25 + float(unprojectedZDistance))
	var zDistanceAsPercent = unprojectedZasPerecentOfRoomHeight / 100
	return  zDistanceAsPercent
	
func convert3dCoordintesTo2d():
	var projectedX : int
	var projectedY : int 
	
	var tX = float(unprojectedX) # in room top left is 0,0, so tx = mouse_x
	var tY = float(unprojectedY) 
	var tZ = float(unprojectedZ) # in room top left is 0,0, so ty = room height - mouse_y
	var t = [tX, tY, tZ]

	# determine size of projected space (trapezoid)
	var desiredHorizonWidth = 520
	var desiredHorizonHeight = room_height - 32
	#desiredHorizonYLocation = 100;  // remember, top of screen is 0, bottom is room_height.
	var trTopLeft = [(room_width - desiredHorizonWidth)/2, desiredHorizonHeight]
	var trTopRight = [room_width - ((room_width - desiredHorizonWidth)/2), desiredHorizonHeight]
	var trBottomLeft = [0,0]
	var trBottomRight = [room_width,0]

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
	#print("T: " + str(t))
	#print("WidthAtProjectedDepth: " + str(WidthAtProjectedDepth))
	var unusedSpaceLeftOfWidthAtDepth = (room_width - WidthAtProjectedDepth) / 2
	#print("unusedSpaceLeftOfWidthAtDepth: " + str(unusedSpaceLeftOfWidthAtDepth))
	## var XAsPercentOfOriginalWidth : float
	var XAsPercentOfOriginalWidth = t[0] / room_width
	#print("XAsPercentOfOriginalWidth: " + str(t[0]) + "/" + str(room_width) + "=" +str(XAsPercentOfOriginalWidth))
	var XPositionOnWidthAtDepth = XAsPercentOfOriginalWidth * WidthAtProjectedDepth
	#print("XPositionOnWidthAtDepth: " + str(XPositionOnWidthAtDepth))
	
	projectedX = unusedSpaceLeftOfWidthAtDepth + XPositionOnWidthAtDepth;
	#clamp(x,0,room_width);// don't let x leave the screen left or screen right;
		
	return [projectedX, projectedY]
	
func set_3d_position():
	var projectedCoordinates = convert3dCoordintesTo2d()
	print("projected coordinates: " + str(projectedCoordinates))
	position.x = projectedCoordinates[0]
	position.y = projectedCoordinates[1]
	#update shadow
	#shadow.position.x = projectedCoordinates[0]
	#shadow.position.y = projectedCoordinates[1]
	
#func set_2d_position():
#	var coords = [unprojectedX, room_height - unprojectedY]
#	print("2d coordinates: " + str(coords))
#	position.x = coords[0]
#	position.y = coords[1]

func determineImageScale () :
	var imageScale = 1 - (determineZAsPercent(unprojectedZ) * 0.9);
	return  imageScale;
		

func set_3d_image_scale () :
	var image_scale = determineImageScale()
	scale = Vector2(image_scale, image_scale)
#	shadow.scale = Vector2(image_scale, image_scale)

func _ready():
	change_state_held()
	#set_3d_image_scale()
	shadow = get_parent().get_node("shadow_2d")
	pass
	
func _process(delta):
	delta_counter += delta;
	# rotation += angular_speed * delta
	#position +=  Vector2.DOWN * movement_speed * delta
	
	match current_state:
		State.HELD:
			set_3d_position()
			set_3d_image_scale()
			pass
		State.RELEASED:
			# apply gravity to upward momentum.
			#print("y velocity:" + str(yVelocity))
			#print("y gravity:" + str(yGravity))
			if (yVelocity + yGravity >= minYVelocity) :
				yVelocity += yGravity; 
				# TBD: do the same for x and z to simulate drag?
			print("x, y, z velocity:" + str(xVelocity) + " " + str(yVelocity) + " " + str(zVelocity))
			# apply momentums to x, y and z
			unprojectedY += yVelocity * delta;
			unprojectedX += xVelocity * delta;
			unprojectedZ += zVelocity * delta;
			# rotate in air
			#var image_angle = get_node("spr_baseball").rotation_degrees 
			#image_angle -= rotationSpeed * sign(xVelocity);
			#get_node("spr_baseball").rotation = image_angle

			# handle coordinate conversation to 2d space (note: do here, for now, b/c only state with movement)
			set_3d_position()
			set_3d_image_scale()
			
			# check to see if we hit the ground	
			if (unprojectedY <= ground) : # for now, stop moving if at ground (y = 0);
				change_state_grounded() # change state
				## game feel fx
				#obj_sound_manager.play_hit_ground();
				#obj_displayManager.start_large_shake();
				# if not upright, rotate to upright
				#sprite_index = bobbingSprite;
				#image_angle = 0;
				# create a "splash" effect (using the wake for this)
		State.GROUNDED:
			#print("delta counter = " + str(delta_counter));
			set_3d_position()
			set_3d_image_scale()
			pass
		_:
			print("I am not a baseball state I know of!")
	shadow.update_location()
	print('baseball position: ' + str(position))
