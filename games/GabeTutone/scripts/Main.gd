extends Node

export var circle_scene : PackedScene
export var cross_scene : PackedScene

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var board_size : int
var cell_size : int
var grid_pos : Vector2
var grid_data : Array
var player : int
var temp_marker
var player_panel_pos : Vector2
var row_sum : int
var col_sum : int
var diagonal1_sum : int
var diagonal2_sum : int
var winner : int
var moves : int

# Called when the node enters the scene tree for the first time.
func _ready():
	board_size = $Board.texture.get_width()
	# divide board size by 3 to get individual cells
	cell_size = board_size / 3
	# get coordinates of player panel on right side of window
	player_panel_pos = $PlayerPanel.get_position()
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			# Check if mouse is on the game board
			if event.position.x < board_size:
				# Convert mouse positon into grid location
				grid_pos = Vector2(event.position / cell_size).floor()
				if grid_data[grid_pos.y][grid_pos.x] == 0:
					moves += 1
					grid_data[grid_pos.y][grid_pos.x] = player
					# place that player's marker
					create_marker(player, grid_pos * cell_size + Vector2(cell_size / 2, cell_size / 2))
					if check_win() != 0:
						get_tree().paused = true
						$GameOverMenu.show()
						if winner == 1:
							$GameOverMenu.get_node("ResultLabel").text = "Player 1 wins!"
						elif winner == -1:
							$GameOverMenu.get_node("ResultLabel").text = "Player 2 wins!"
					# Check if the board has been filled
					elif moves == 9:
						get_tree().paused = true
						$GameOverMenu.show()
						$GameOverMenu.get_node("ResultLabel").text = "It's a tie!"
					player *= -1
					# Update the player's marker
					temp_marker.queue_free()
					create_marker(player, player_panel_pos + Vector2(cell_size / 2, cell_size / 2), true)
					print("State of the grid: ", grid_data)

func new_game():
	player = 1
	moves = 0
	winner = 0
	grid_data = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0],
	]
	# Reset the check_win variables
	row_sum = 0
	col_sum = 0
	diagonal1_sum = 0
	diagonal2_sum = 0
	# Clear existing markers
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	# create marker to show starting player's turn
	create_marker(player, player_panel_pos + Vector2(cell_size / 2, cell_size / 2), true)
	$GameOverMenu.hide()
	# Unpause the game
	get_tree().paused = false
	
	
func create_marker(player, position, temp = false):
	# create a marker node and add it as a child
	if player == 1:
		var circle = circle_scene.instance()
		circle.position = position
		add_child(circle)
		if temp: temp_marker = circle
	else:
		var cross = cross_scene.instance()
		cross.position = position
		add_child(cross)
		if temp: temp_marker = cross

func check_win():
	# add up the markers in each row, column and diagonal
	for i in len(grid_data):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diagonal1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diagonal2_sum = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]
		# print("Row sum is: ", row_sum, ", Col sum is: ", col_sum, ", diag1 sum is: ", diagonal1_sum, ", diag2 sum is: ", diagonal2_sum)
		if row_sum == 3 or col_sum == 3 or diagonal1_sum == 3 or diagonal2_sum == 3:
			winner = 1
		elif row_sum == -3 or col_sum == -3 or diagonal1_sum == -3 or diagonal2_sum == -3:
			winner = -1

	return winner


func _on_GameOverMenu_restart():
	new_game()
