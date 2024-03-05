extends CanvasLayer

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("YOU DIED")
#	yield($MessageTimer, 'timeout')
#	$Message.text = "Dodge\nthe Creeps"
#	$Message.show()
	
func update_score(score):
	$nutritionLabel.text = str(score)
