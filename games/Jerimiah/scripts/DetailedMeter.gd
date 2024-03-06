extends Node2D

var timer: Timer

func _process(delta):
	if self.visible and timer:
		$gaugeArm.rotation_degrees = clamp(lerp(-90, 90, timer.time_left / 120), -90, 90)
		
		if timer.time_left <= 0:
			$ExpiredPop.visible = true
		else:
			$ExpiredPop.visible = false
	
