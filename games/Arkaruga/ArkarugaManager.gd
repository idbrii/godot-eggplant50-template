extends Node2D

const Types = preload("res://games/Arkaruga/Scripts/Arkaruga-Types.gd")

export (PackedScene) var ballScene
export (int) var startLives = 5
export var secondsToMaxSpeed = 600
export var secondsLostOnDeath = 60
export (int) var bonusLifePoints = 100
export (int) var multiballCombo = 10
export (float) var multiballAngleOffset = 45

onready var uiManager = get_node("%UILayer")
onready var paddle = get_node("%Paddle")
onready var ballContainer = get_node("%BallContainer")
onready var brickContainer = get_node("%BrickContainer")

onready var _startGameTimer : Timer = $StartGameTimer
onready var _endGameTimer : Timer = $EndGameTimer
onready var _lostBallTimer : Timer = $LostBallTimer

var activeColor = Types.ElementColor.BLUE

var _isGameRunning = false
var _livesRemaining : int
var _score : int
var _combo : int
var _totalGameDuration : float
var _gameDurationForSpeed : float

func _ready():
	setActiveColor(Types.ElementColor.GREEN)
	_livesRemaining = startLives
	
func _input(event):
	if event.is_action_pressed("action1"):
		if _isGameRunning:
			swapActiveColor()
		
func _process(delta):
	if _isGameRunning && getAnyBallsActive():
		_totalGameDuration += delta
		_gameDurationForSpeed += delta
	
	_processUI(delta)
	
func _processUI(_delta):
	if !uiManager:
		return
	
	uiManager.setScoreValue(_score)
	uiManager.setComboValue(_combo)
	uiManager.setLives(_livesRemaining)
	uiManager.setTime(int(_totalGameDuration))
		
func onBallLost(_ball):
	# reset our combo whenever a ball goes offscreen
	_combo = 0 
	
	# there are no balls left -- respawn!
	if !getAnyBallsActive():
		if _livesRemaining > 0:
			_lostBallTimer.start()
			yield(_lostBallTimer, "timeout")
			loseLife()
			_respawnBall()
		else:
			endGame()
			
func onBrickSpawnAreaClear():
	print("CLEAR!")
		
func getAnyBallsActive():
	var balls = get_tree().get_nodes_in_group("Balls")
	for ball in balls:
		if ball.getIsActive():
			return true
			
	return false
	
func startGame():
	if uiManager:
		uiManager.setStartScreenVisible(false)
		uiManager.setSidebarResultsVisible(false)
	
	_startGameTimer.start()
	yield(_startGameTimer, "timeout")
	
	_isGameRunning = true
	_livesRemaining = startLives
	_totalGameDuration = 0
	_gameDurationForSpeed = 0
	_score = 0
	_combo = 0
	
	# spend a life on the initial ball so the UI matches the desired count
	loseLife()
	_respawnBall()
	
func endGame():
	_isGameRunning = false
	
	_endGameTimer.start()
	yield(_endGameTimer, "timeout")
	
	uiManager.setEndScreenVisible(true)
	uiManager.setSidebarResultsVisible(true)
	
func addScore(points : int):
	var prevLiveIncrement = _score / bonusLifePoints
	_score += points
	
	if _score / bonusLifePoints > prevLiveIncrement:
		# TODO: Play sound
		gainLife()
		if uiManager:
			uiManager.playToast("BALL GET!")
		
	
func addCombo(ball, value : int = 1):
	var comboForNextMultiball = getComboForNextMultiball()
	_combo += value
	
	if _combo >= comboForNextMultiball:
		# TODO: Play sound
		_spawnMultiball(ball)
		if uiManager:
			uiManager.playToast("MULTI BALL!")

func resetCombo():
	_combo = 0
	
func loseLife(): 
	if _livesRemaining > 0:
		_livesRemaining -= 1
		# slow the game down after losing a life
		_gameDurationForSpeed = max(0.0, _gameDurationForSpeed - secondsLostOnDeath)
	
func gainLife():
	_livesRemaining += 1

func swapActiveColor():
	match activeColor:
		Types.ElementColor.BLUE:
			setActiveColor(Types.ElementColor.GREEN)
		Types.ElementColor.GREEN:
			setActiveColor(Types.ElementColor.BLUE)

func setActiveColor(color: int):
	activeColor = color
	get_tree().call_group("Colorized", "onActiveColorChanged", color)

func getIsGameRunning() -> bool:
	return _isGameRunning

func getSpeedModifierRatio() -> float:
	return inverse_lerp(0.0, secondsToMaxSpeed, _gameDurationForSpeed)

func getComboForNextMultiball() -> int:
	var ballCount = get_tree().get_nodes_in_group("Balls").size()
	var minCombo = multiballCombo * max(1, ballCount)
	return minCombo

func _respawnBall():
	var ballInstance = ballScene.instance()
	ballInstance.attachToPaddle(paddle)
	ballInstance.startLaunchTimer()
	
func _spawnMultiball(ball):
	var newBall = ballScene.instance()
	ballContainer.add_child(newBall)
	newBall.global_position = ball.global_position
	var velocity = -ball.velocity
	var angleOffset = multiballAngleOffset
	if randf() > .5:
		angleOffset *= -1
	velocity = velocity.rotated(deg2rad(angleOffset))
	newBall.velocity = velocity
