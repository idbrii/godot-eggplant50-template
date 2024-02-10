extends State
class_name BaseballWindup


export var power = 0

func Update(delta: float):
	# move down
	#position +=  Vector2.DOWN * movement_speed * delta
	power += 1

	# listen for input, then switch to released	
	if Input.is_action_just_released("action1"):
		Transitioned.emit(self, "Release")
