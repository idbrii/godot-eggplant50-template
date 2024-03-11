extends Node2D

var tetris_pieces = [preload("res://games/Ooks/blocks/block_straight.tscn"),preload("res://games/Ooks/blocks/block_square.tscn"),preload("res://games/Ooks/blocks/block_Lr.tscn"),preload("res://games/Ooks/blocks/block_Ll.tscn"),preload("res://games/Ooks/blocks/block_k.tscn"),preload("res://games/Ooks/blocks/block_s.tscn"),preload("res://games/Ooks/blocks/block_z.tscn")]
onready var random = RandomNumberGenerator.new()
var time_between_spawns = 0.0
var tetromino_type = 0 #0-6 corresponding to tetris_pieces array above
var target_left = -5 #needs to be a multiple of 5
var target_mid = 310 #needs to be a multiple of 5
var target_right = 625 #needs to be a multiple of 5

var challenge_mode = false
var random_mode = true
var profile_mode = false
onready var spawnPosition = $spawnLocationMid.position
var won = false

var discoveredLeft = false
var discoveredRight = false

# Called when the node enters the scene tree for the first time.
func _ready():
	random.randomize()
	tetromino_type = random.randi_range(0, tetris_pieces.size()-1)
	var instance = tetris_pieces[tetromino_type].instance()
	instance.tetromino_type = tetromino_type
	instance.position = spawnPosition
	add_child(instance)
	yield(get_tree().create_timer(2.0), "timeout")
	$EscapeLabel.visible = false
	$RandomLabel.visible = true
#	yield(get_tree().create_timer(2.0), "timeout")
#	$UI/GameMenu.visible = true
#	$UI/GameMenu.call_deferred("popup")

func _child_fell(piece_position):
	$fallAudio.position = piece_position
	$fallAudio.play()

func _child_rototated(piece_position):
	$rotateAudio.position = piece_position
	$rotateAudio.play()

func _process(delta):
	time_between_spawns += delta
	if $Player.position.x < 153:
		if $Camera2D.position.x != target_left:
			$Camera2D.position.x -= 5
			random_mode = false
			profile_mode = true
			spawnPosition = $spawnLocationLeft.position
			$Blackout1.visible = false
			if not discoveredLeft:
				discoveredLeft = true
				$discoverAudio.play()
	elif $Player.position.x > 468:
		if $Camera2D.position.x != target_right:
			$Camera2D.position.x += 5
			random_mode = false
			challenge_mode = true
			spawnPosition = $spawnLocationRight.position
			$Player.challenge_mode = true
			$Blackout2.visible = false
			if not discoveredRight:
				discoveredRight = true
				$discoverAudio.play()
	else:
		if $Camera2D.position.x > target_mid:
			$Camera2D.position.x -= 5
			random_mode = true
			challenge_mode = false
			spawnPosition = $spawnLocationMid.position
		elif $Camera2D.position.x < target_mid:
			$Camera2D.position.x += 5
			random_mode = true
			profile_mode = false
			spawnPosition = $spawnLocationMid.position

func child_sending_next():
	if time_between_spawns > 0.25:
		time_between_spawns = 0.0
		tetromino_type = random.randi_range(0, tetris_pieces.size()-1)
		var instance = tetris_pieces[tetromino_type].instance()
		instance.tetromino_type = tetromino_type
		instance.position = spawnPosition
		instance.random_mode = random_mode
		instance.challenge_mode = challenge_mode
		instance.profile_mode = profile_mode
		add_child(instance)
		
#		print("spawn")


func _on_GoalArea_body_entered(body):
	if body == $Player:
		if not won:
			won = true
			$winAudio.play()
#		print(body)
		$Player.visible = false
		$YouWinLabelLeft.visible = true
		$YouWinLabelMid.visible = true
		$YouWinLabelRight.visible = true
		yield(get_tree().create_timer(2.0), "timeout")
		$UI/GameMenu.visible = true
		$UI/GameMenu.call_deferred("popup")
		
