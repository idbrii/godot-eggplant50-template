extends Node2D

const Types = preload("res://games/Arkaruga/Scripts/Arkaruga-Types.gd")

export (PackedScene) var ballScene
export var lostBallResetDelay = 1
export var startLives = 3
export var secondsToMaxSpeed = 600
export var secondsLostOnDeath = 60

onready var paddle = get_node("%Paddle")
onready var ballContainer = get_node("%BallContainer")
onready var brickContainer = get_node("%BrickContainer")

var activeColor = Types.ElementColor.BLUE

var _isGameRunning = false
var _livesRemaining : int
var _totalGameDuration : float
var _gameDurationForSpeed : float

func _ready():
	setActiveColor(Types.ElementColor.GREEN)
	
	# TODO: Support actual starting / restarting
	yield(get_tree().create_timer(.1), "timeout")
	
	startGame()
	
func _input(event):
	if event.is_action_pressed("action1"):
		swapActiveColor()
		
func _process(delta):
	if _isGameRunning && getAnyBallsActive():
		_totalGameDuration += delta
		_gameDurationForSpeed += delta
		
		
func onBallLost(ball):
	# there are no balls left -- respawn!
	if !getAnyBallsActive():
		loseLife()
	
		if _livesRemaining > 0:
			yield(get_tree().create_timer(lostBallResetDelay), "timeout")
			_respawnBall()
		
func getAnyBallsActive():
	var balls = get_tree().get_nodes_in_group("Balls")
	for ball in balls:
		if ball.getIsActive():
			return true
			
	return false
	
func startGame():
	_isGameRunning = true
	_livesRemaining = startLives
	_totalGameDuration = 0
	_gameDurationForSpeed = 0
	_respawnBall()
	
func endGame():
	_isGameRunning = false
	
func loseLife():
	if _livesRemaining > 0:
		_livesRemaining -= 1
		_gameDurationForSpeed = max(0.0, _gameDurationForSpeed - secondsLostOnDeath)

func swapActiveColor():
	match activeColor:
		Types.ElementColor.BLUE:
			setActiveColor(Types.ElementColor.GREEN)
		Types.ElementColor.GREEN:
			setActiveColor(Types.ElementColor.BLUE)

func setActiveColor(color: int):
	activeColor = color
	get_tree().call_group("Colorized", "onActiveColorChanged", color)
	
func getSpeedModifierRatio():
	return inverse_lerp(0.0, secondsToMaxSpeed, _gameDurationForSpeed)
	
func _respawnBall():
	var ballInstance = ballScene.instance()
	ballInstance.attachToPaddle(paddle)
	ballInstance.startLaunchTimer()
	return
