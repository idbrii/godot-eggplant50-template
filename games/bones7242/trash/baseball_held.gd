extends State
class_name BaseballHeld

func Update(delta: float):
	
	# listen for input, then switch to released	
	if Input.is_action_pressed("action1"):
		Transitioned.emit(self, "BaseballWindup")


