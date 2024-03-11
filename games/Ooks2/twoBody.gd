extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var body1forcing = true
var body2forcing = false
var force_timeout_time = 0.5
var h = 25#43

# Called when the node enters the scene tree for the first time.
func _ready():
	$RigidBody2D.other = $RigidBody2D2
	$RigidBody2D2.other = $RigidBody2D
	$RigidBody2D.forcing = body1forcing
	$RigidBody2D2.forcing = body2forcing
	$RigidBody2D/hands/closed.visible = not body1forcing
	$RigidBody2D/hands/open.visible = body1forcing
	$RigidBody2D2/hands/closed.visible = not body2forcing
	$RigidBody2D2/hands/open.visible = body2forcing


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	$RigidBody2D/hands.rotation_degrees = -1*$RigidBody2D.rotation_degrees+90
	$RigidBody2D2/hands.rotation_degrees = -1*$RigidBody2D2.rotation_degrees+90
	var tempD = ($RigidBody2D2.position - $RigidBody2D.position).length()
#	var tempX = ($RigidBody2D2.position - $RigidBody2D.position).x #
	var tempX = ($RigidBody2D2.get_global_transform().origin.x - $RigidBody2D.get_global_transform().origin.x)
	var tempY = ($RigidBody2D2.position - $RigidBody2D.position).y
#	$RigidBody2D2/hands/ColorRect.rect_rotation = (asin(tempD/2/h))*180/PI
#	$RigidBody2D/hands/ColorRect.rect_rotation = (asin(tempD/2/h))*180/PI
#	if tempX < 0:
#		$RigidBody2D/hands/ColorRect.rect_rotation *= -1
#	else:
#		$RigidBody2D2/hands/ColorRect.rect_rotation *= -1
	if true:#tempD >= 2*h:
		$RigidBody2D/hands/ColorRect.rect_size.y = tempD
		#$RigidBody2D/hands/ColorRect.rect_size.x = (50/(tempD+1))
		if tempY == 0:
			tempY = 1 #avoid divide by 0
		$RigidBody2D2/hands/ColorRect.rect_rotation = (atan(($RigidBody2D.position - $RigidBody2D2.position).x/tempY) )*180/PI - 90
		$RigidBody2D/hands/ColorRect.rect_rotation = (atan(($RigidBody2D.position - $RigidBody2D2.position).x/tempY) )*180/PI - 90
		if tempX > 0:
			#$RigidBody2D2/hands/ColorRect.rect_rotation = fmod(($RigidBody2D2/hands/ColorRect.rect_rotation+180),360)
			$RigidBody2D2/hands/ColorRect.rect_rotation += 180
		else:
			$RigidBody2D/hands/ColorRect.rect_rotation += 180
	if Input.is_action_just_pressed("action1"):
#		print($RigidBody2D2/hands/ColorRect.rect_rotation)
#		print(tempX)
		var temp = body1forcing
		body1forcing = body2forcing
		body2forcing = temp
		$RigidBody2D.forcing = false
		$RigidBody2D/hands/closed.visible = true
		$RigidBody2D/hands/open.visible = false
		$RigidBody2D2.forcing = false
		$RigidBody2D2/hands/closed.visible = true
		$RigidBody2D2/hands/open.visible = false
		yield(get_tree().create_timer(force_timeout_time), "timeout")
		$RigidBody2D.forcing = body1forcing
		$RigidBody2D/hands/closed.visible = not body1forcing
		$RigidBody2D/hands/open.visible = body1forcing
		$RigidBody2D2.forcing = body2forcing
		$RigidBody2D2/hands/closed.visible = not body2forcing
		$RigidBody2D2/hands/open.visible = body2forcing
		
