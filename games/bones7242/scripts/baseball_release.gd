extends State
class_name BaseballWindup

var gravity

func Update(delta: float):
	# move down
	power -= gravity
	#position +=  Vector2.DOWN * movement_speed * delta
	

	# listen for input, then switch to released	
	if Input.is_action_just_released("action1"):
		Transitioned.emit(self, "Release")
