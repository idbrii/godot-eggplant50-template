extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_area_entered(area):
	print("jsome entered my area!")
	if area.name == "baseball_area2d":
		print("baseball entered my area!")
		# Assign new direction.
		#area.direction = Vector2(_ball_dir, randf() * 2 - 1).normalized()
		
	if area.name == "bat_area2d":
		print("bat entered my area!")
		# Assign new direction.
		#area.direction = Vector2(_ball_dir, randf() * 2 - 1).normalized()
