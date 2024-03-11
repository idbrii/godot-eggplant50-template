extends Area2D


var xlocation : int
var ylocation : int
var zlocation : int
var room_height = 360
var room_width = 640

func determineZAsPercent (unprojectedZDistance) :
	var unprojectedZasPerecentOfRoomHeight = 100 * float(unprojectedZDistance) / (25 + float(unprojectedZDistance))
	var zDistanceAsPercent = unprojectedZasPerecentOfRoomHeight / 100
	return  zDistanceAsPercent

func convert3dCoordintesTo2d(unprojectedX, unprojectedY, unprojectedZ):
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

func update_location():
	var baseball = get_parent().get_node("baseball_area2d")
	print('baseball position from shadow: ' + str(baseball.position))
	print('shadow position: ' + str(position))
	# set positions
	xlocation = baseball.unprojectedX
	ylocation = 0
	zlocation = baseball.unprojectedZ
	var projected_coords = convert3dCoordintesTo2d(xlocation, ylocation, zlocation)
	position.x = projected_coords[0]
	position.y = projected_coords[1]
		# set scale 
	scale = baseball.scale


func _process(delta):
	pass
