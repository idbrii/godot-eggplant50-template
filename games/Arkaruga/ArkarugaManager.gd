extends Node2D

const Types = preload("res://games/Arkaruga/Scripts/Arkaruga-Types.gd")

export (PackedScene) var ballScene
export var lostBallResetDelay = 1
export var startLives = 3

onready var _ballContainer = get_node("%Balls")
onready var _paddle = get_node("%Paddle")

var _activeColor = Types.ElementColor.BLUE
var _livesRemaining : int

func _ready():
	setActiveColor(Types.ElementColor.GREEN)
	
	# TODO: Support actual starting / restarting
	yield(get_tree().create_timer(.1), "timeout")
	
	startGame()
	
func _input(event):
	if event.is_action_pressed("action1"):
		swapActiveColor()
		
		
func onBallLost(ball):
	loseLife()
	
	if _livesRemaining > 0:
		yield(get_tree().create_timer(lostBallResetDelay), "timeout")
		_respawnBall()
	
func startGame():
	_livesRemaining = startLives
	_respawnBall()
	
func loseLife():
	if _livesRemaining > 0:
		_livesRemaining -= 1

func swapActiveColor():
	match _activeColor:
		Types.ElementColor.BLUE:
			setActiveColor(Types.ElementColor.GREEN)
		Types.ElementColor.GREEN:
			setActiveColor(Types.ElementColor.BLUE)

func setActiveColor(color: int):
	_activeColor = color
	get_tree().call_group("Colorized", "onActiveColorChanged", color)
	
func _respawnBall():
	var ballInstance = ballScene.instance()
	ballInstance.initialize(self, _ballContainer)
	ballInstance.attachToPaddle(_paddle)
	ballInstance.startLaunchTimer()
	return
