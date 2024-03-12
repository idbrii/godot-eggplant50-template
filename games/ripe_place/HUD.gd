extends CanvasLayer

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over(fruit_count: int, win: bool):
	if win:
		$gameOverRect/youDiedLabel.text = \
		'Congratulations! You are one of the great fruit bats of our time!'
		$gameOverRect/scoreLabel.text = 'You ate ' + str(fruit_count) \
		+ ' ripe fruits!'
	else:
		$gameOverRect/youDiedLabel.text = 'You have run out of nutrition. Unfortunate!'
		$gameOverRect/scoreLabel.text = 'But at least you ate ' + str(fruit_count) \
		+ ' ripe fruits!'

	$gameOverRect.visible = true

	# Give button focus to be gamepad clickable.
	$gameOverRect/newGameButton.grab_focus()
	# Disable button for a second to prevent accidental clicks.
	$gameOverRect/newGameButton.disabled = true
	yield(get_tree().create_timer(1), "timeout")
	$gameOverRect/newGameButton.disabled = false

func update_score(score):
	$nutritionLabel.text = str(score)

func _on_newGameButton_button_up():
	$gameOverRect.visible = false
	emit_signal('start_game')
