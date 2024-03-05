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
	$youDiedLabel.visible = true
	$newGameButton.visible = true
	
func update_score(score):
	$nutritionLabel.text = str(score)

func _on_newGameButton_button_up():
	$youDiedLabel.visible = false
	$newGameButton.visible = false
	emit_signal('start_game')
