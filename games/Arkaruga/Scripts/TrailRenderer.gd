# GitHub Project Page: https://github.com/dbp8890/motion-trails

extends Line2D

export var emitting = true
export var minPointDistance = 1
export var length = 50

var lastPointAddTime = -1
var minTimeDelta = 0.0

func _ready():
	lastPointAddTime = -1

func _process(delta):
	# keep us at the origin so our points are effectively in world space
	global_position = Vector2(0,0)
	global_rotation = 0
	
	if emitting:
		var pointCount = get_point_count()
		var point = get_parent().global_position
		if pointCount == 0:
			add_point(point)
		else:
			var lastPoint = points[pointCount - 1]
			if lastPoint.distance_to(point) >= minPointDistance:
				add_point(point)
				
	limitLength()
				
func limitLength():
	var remainingLength = length
	var totalPointCount = get_point_count()
	var validPointCount = 0
	
	if totalPointCount == 0:
		return
		
	# use the most recent point as our start position
	var prevPosition = Vector2.ZERO

	for i in totalPointCount:
		# iterate backwards
		var index = totalPointCount - (i + 1)
		var point = points[index]
		
		if i > 0:
			var distance = point.distance_to(prevPosition)
			if remainingLength - distance > 0:
				remainingLength -= distance
			else:
				var direction = prevPosition.direction_to(point)
				var newPoint = prevPosition + (direction * remainingLength)
				set_point_position(index, newPoint)
				break
		
		prevPosition = point
		validPointCount += 1
	
	if validPointCount < totalPointCount:
		var pointsToRemove = totalPointCount - validPointCount
		for i in pointsToRemove:
			remove_point(0)
