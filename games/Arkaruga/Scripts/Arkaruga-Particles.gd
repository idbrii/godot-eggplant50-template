extends CPUParticles2D

func _ready():
	emitting = true
	$Timer.start(lifetime * 1.5)
	yield($Timer, "timeout")
	queue_free()
