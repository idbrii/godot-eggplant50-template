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
onready var boardAnim = $BoardAnim
# MiniMax variables
var score : int
var best : int
var bestVal : int
var bestMove : Array
var moveVal : int
var CPUMove: Array
var CPUMoveV : Vector2
var TopLeft = Vector2(60.0, 60.0)
var	TopMiddle = Vector2(180, 60)
var	TopRight = Vector2(300, 60)
var	MiddleLeft = Vector2(60, 180)
var	MiddleMiddle = Vector2(180, 180)
var	MiddleRight = Vector2(300, 180)
var	BottomLeft = Vector2(60, 300)
var	BottomMiddle = Vector2(180, 300)
var	BottomRight = Vector2(300, 300)

# Called when the node enters the scene tree for the first time.
func _ready():
	boardAnim.play("run")
	board_size = 360
	# divide board size by 3 to get individual cells
	cell_size = board_size / 3
	# get coordinates of player panel on right side of window
	player_panel_pos = $PlayerPanel.get_position()
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _input(event):
	if player == 1:
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
	else:
		CPUMove = findBestMove(grid_data)
		print("The CPU Move is ", CPUMove)
		moves += 1
		if CPUMove == [0,0]:
			CPUMoveV = TopLeft
		elif CPUMove == [0,1]:
			CPUMoveV = TopMiddle
		elif CPUMove == [0,2]:
			CPUMoveV = TopRight		
		elif CPUMove == [1,0]:
			CPUMoveV = MiddleLeft
		elif CPUMove == [1,1]:
			CPUMoveV = MiddleMiddle
		elif CPUMove == [1,2]:
			CPUMoveV = MiddleRight
		elif CPUMove == [2,0]:
			CPUMoveV = BottomLeft
		elif CPUMove == [2,1]:
			CPUMoveV = BottomMiddle
		elif CPUMove == [2,2]:
			CPUMoveV = BottomRight
		create_marker(player, CPUMoveV)
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
		circle.play("run")
		circle.position = position
		add_child(circle)
		if temp: temp_marker = circle
	else:
		var cross = cross_scene.instance()
		cross.play("run")
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
		if row_sum == 3 or col_sum == 3 or diagonal1_sum == 3 or diagonal2_sum == 3:
			winner = 1
		elif row_sum == -3 or col_sum == -3 or diagonal1_sum == -3 or diagonal2_sum == -3:
			winner = -1

	return winner


func _on_GameOverMenu_restart():
	new_game()

# SOURCE: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html
var MInMaxPlayer = 1
var opponent = 2
# This function returns true if there are moves  
# remaining on the board. It returns false if  
# there are no moves left to play.  
func isMovesLeft(board) :
	for i in range(3) : 
		for j in range(3) : 
			if (board[i][j] == 0) : 
				return true 
	return false
  
# This is the evaluation function as discussed  
# in the previous article ( http://goo.gl/sJgv68 )  
func evaluate(b) :
	# Checking for Rows for X or O victory.  
	for row in range(3) :
		if (b[row][0] == b[row][1] and b[row][1] == b[row][2]) :
			if (b[row][0] == MInMaxPlayer) : 
				return 10
			elif (b[row][0] == opponent) : 
				return -10
	# Checking for Columns for X or O victory.  
	for col in range(3) : 
		if (b[0][col] == b[1][col] and b[1][col] == b[2][col]) : 
			if (b[0][col] == MInMaxPlayer) :  
				return 10
			elif (b[0][col] == opponent) : 
				return -10
	# Checking for Diagonals for X or O victory.  
	if (b[0][0] == b[1][1] and b[1][1] == b[2][2]) :  
		if (b[0][0] == MInMaxPlayer) : 
			return 10
		elif (b[0][0] == opponent) : 
			return -10
	if (b[0][2] == b[1][1] and b[1][1] == b[2][0]) :  
		if (b[0][2] == MInMaxPlayer) : 
			return 10
		elif (b[0][2] == opponent) : 
			return -10
	# Else if none of them have won then return 0  
	return 0
  
# This is the minimax function. It considers all  
# the possible ways the game can go and returns  
# the value of the board  
func minimax(board, depth, isMax) :  
	score = evaluate(board) 
	# If Maximizer has won the game return their  
	# evaluated score  
	if (score == 10) :  
		return score 
	# If Minimizer has won the game return their  
	# evaluated score  
	if (score == -10) : 
		return score 
	# If there are no more moves and no winner then  
	# it is a tie  
	if (isMovesLeft(board) == false) : 
		return 0
	# If this is maximizer's move  
	if (isMax) :      
		best = -1000 
		# Traverse all cells  
		for i in range(3) :          
			for j in range(3) : 
				# Check if cell is empty  
				if (board[i][j]==0) : 
					# Make the move  
					board[i][j] = MInMaxPlayer  
					# Call minimax recursively and choose  
					# the maximum value  
					best = max( best, minimax(board, depth + 1, not isMax) ) 
					# Undo the move  
					board[i][j] = 0
		return best 
	# If this minimizer's move  
	else : 
		best = 1000 
		# Traverse all cells  
		for i in range(3) :          
			for j in range(3) : 
				# Check if cell is empty  
				if (board[i][j] == 0) : 
					# Make the move  
					board[i][j] = opponent  
					# Call minimax recursively and choose  
					# the minimum value  
					best = min(best, minimax(board, depth + 1, not isMax)) 
					# Undo the move  
					board[i][j] = 0
		return best 
  
# This will return the best possible move for the player  
func findBestMove(board) :  
	bestVal = -1000 
	bestMove = [-1, -1] 
	# Traverse all cells, evaluate minimax function for  
	# all empty cells. And return the cell with optimal  
	# value.  
	for i in range(3) :      
		for j in range(3) : 
			# Check if cell is empty  
			if (board[i][j] == 0) :  
				# Make the move  
				board[i][j] = MInMaxPlayer 
				# compute evaluation function for this  
				# move.  
				moveVal = minimax(board, 0, false)  
				# Undo the move  
				board[i][j] = 0 
				# If the value of the current move is  
				# more than the best value, then update  
				# best/  
				if (moveVal > bestVal) :                 
					bestMove = [i, j]
					bestVal = moveVal 
	print("The value of the best Move is :", bestVal) 
	return bestMove
