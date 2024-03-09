extends Sprite

var room_height = 360

func determineZAsPercent (unprojectedZDistance) :
	var unprojectedZasPerecentOfRoomHeight = 100 * float(unprojectedZDistance) / (25 + float(unprojectedZDistance))
	var zDistanceAsPercent = unprojectedZasPerecentOfRoomHeight / 100
	return  zDistanceAsPercent

func _process(delta):
	# set x position
	var baseball = get_parent().get_node("baseball_area2d")
	position.x = baseball.position.x 
	# set y position
	var unprojectedZ = baseball.unprojectedZ
	var zDistanceAsPercent = determineZAsPercent(unprojectedZ)
	var desiredHorizonHeight = room_height - 32
	var projectedY = room_height - (desiredHorizonHeight * zDistanceAsPercent)
	
	position.y = projectedY
	# set scale
	scale = baseball.scale
	
