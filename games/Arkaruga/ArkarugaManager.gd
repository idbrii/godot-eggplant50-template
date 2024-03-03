extends Node2D

const BrickGroupLibrary = preload("res://games/Arkaruga/Scripts/Arkaruga-BrickGroupLibrary.gd")
const Types = preload("res://games/Arkaruga/Scripts/Arkaruga-Types.gd")
const InitialGroupSpawnCount : int = 5
const ConfigSavePath : String = "user://arkaruga.cfg"
const HighScoreSaveCategory : String = "HighScores"

export (Resource) var brickGroupLibrary
export (PackedScene) var ballScene
export (int) var startLives = 5
export var secondsToMaxSpeed = 360
export var secondsLostOnDeath = 60
export (int) var bonusLifePoints = 100
export (int) var multiballCombo = 10
export (float) var multiballAngleOffset = 45.0
export (float) var mediumGroupChanceIncrement = .1
export (float) var hardGroupChanceIncrement = .05

onready var uiManager = get_node("%UILayer")
onready var paddle = get_node("%Paddle")
onready var ballContainer = get_node("%BallContainer")
onready var brickContainer = get_node("%BrickContainer")
onready var brickGroupSpawnPoint = get_node("%BrickGroupSpawnPoint")

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
var _lastSpawnedBrickGroup : Node2D
var _mediumGroupChance : float
var _hardGroupChance : float
var _bestScore : int
var _bestTime : float

func _ready():
	_loadHighScores()
	setActiveColor(Types.ElementColor.GREEN)
	
	# set our initial lives so the UI fills out
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
	# this can get called while the scene is being torn down
	if !is_inside_tree():
		return
	
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
			
func onBrickSpawnAreaClear(brickGroup : Node2D):
	# this can get called while the scene is being torn down
	if !is_inside_tree():
		return
	
	if brickGroup == _lastSpawnedBrickGroup && is_instance_valid(brickGroup):
			call_deferred("_spawnBrickGroup")
		
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
		uiManager.setBestScoreVisible(false)
		uiManager.setBestTimeVisible(false)
		
	randomize()
		
	_lastSpawnedBrickGroup = null
	_clearBricks()
	for n in InitialGroupSpawnCount:
		_spawnBrickGroup()
	
	_startGameTimer.start()
	yield(_startGameTimer, "timeout")
	
	_isGameRunning = true
	_livesRemaining = startLives
	_totalGameDuration = 0
	_gameDurationForSpeed = 0
	_score = 0
	_combo = 0
	_mediumGroupChance = 0
	_hardGroupChance = 0
	
	# spend a life on the initial ball so the UI matches the desired count
	loseLife()
	_respawnBall()
	
func endGame():
	_isGameRunning = false
	
	_endGameTimer.start()
	yield(_endGameTimer, "timeout")
	
	uiManager.setEndScreenVisible(true)
	uiManager.setSidebarResultsVisible(true)
	
	uiManager.setBestScoreVisible(_score > _bestScore)
	uiManager.setBestTimeVisible(_totalGameDuration > _bestTime)
	
	_bestScore = max(_bestScore, _score)
	_bestTime = max(_totalGameDuration, _bestTime)
	
	_saveHighScores()
	
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

func _clearBricks():
	var brickGroups = get_tree().get_nodes_in_group("BrickGroups")
	for group in brickGroups:
		group.queue_free()

	var bricks = get_tree().get_nodes_in_group("Bricks")	
	for brick in bricks:
		brick.queue_free()
		
func _spawnBrickGroup():
	var library : BrickGroupLibrary = brickGroupLibrary
	var group = null
	if randf() < _hardGroupChance:
		group = library.getRandomHardGroup()
		_hardGroupChance = 0
	elif randf() < _mediumGroupChance:
		group = library.getRandomMedGroup()
		_mediumGroupChance = 0
	else:
		group = library.getRandomEasyGroup()
		_mediumGroupChance += mediumGroupChanceIncrement
		_hardGroupChance += hardGroupChanceIncrement
	
	var spawnPosition = brickGroupSpawnPoint.global_position
	if _lastSpawnedBrickGroup:
		spawnPosition = _lastSpawnedBrickGroup.getNextGroupSpawnGlobalPosition()
	
	var groupInstance = group.instance()
	groupInstance.global_position = spawnPosition
	brickContainer.add_child(groupInstance)
	
	_lastSpawnedBrickGroup = groupInstance

func _loadHighScores():
	var config = ConfigFile.new()
	var err = config.load(ConfigSavePath)

	if err == OK:
		_bestScore = config.get_value(HighScoreSaveCategory, "Score")
		_bestTime = config.get_value(HighScoreSaveCategory, "Time")
	else:
		_bestScore = 0
		_bestTime = 0

func _saveHighScores():
	var config = ConfigFile.new()
	config.set_value(HighScoreSaveCategory, "Score", _bestScore)
	config.set_value(HighScoreSaveCategory, "Time", _bestTime)
	config.save(ConfigSavePath)
	pass
