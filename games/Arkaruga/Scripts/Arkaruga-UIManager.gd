extends CanvasLayer

export (Color) var _toastColor = Color.white
export (float) var _toastDuration = .9
export (float) var _valuePunchScale = 1.2
export (float) var _valuePunchDuration = .25

onready var _scoreContainer : Control = $Sidebar/Margins/VBoxContainer/ScoreContainer
onready var _scoreValueLabel : Label = $Sidebar/Margins/VBoxContainer/ScoreContainer/ScoreValueControl/Label
onready var _scoreNewBestControl : Control = $Sidebar/Margins/VBoxContainer/ScoreContainer/ScoreValueControl/NewBest
onready var _comboContainer : Control = $Sidebar/Margins/VBoxContainer/ComboContainer
onready var _comboValueLabel : Label = $Sidebar/Margins/VBoxContainer/ComboContainer/ComboValueControl/Label
onready var _timeContainer : Control = $Sidebar/Margins/VBoxContainer/TimeContainer
onready var _timeValueLabel : Label = $Sidebar/Margins/VBoxContainer/TimeContainer/TimeValueControl/Label
onready var _timeNewBestControl : Control = $Sidebar/Margins/VBoxContainer/TimeContainer/TimeValueControl/NewBest
onready var _livesContainer : Control = $Sidebar/Margins/VBoxContainer/BallContainer
onready var _livesTextures : Control = $Sidebar/Margins/VBoxContainer/BallContainer/BallTextures
onready var _toastLabel : Label = $Game/ToastLabel

var _scoreValue = -1
var _comboValue = -1
var _lives = -1
var _seconds = -1
var _scoreTween : SceneTreeTween = null
var _comboTween : SceneTreeTween = null
var _toastTween : SceneTreeTween = null

func _ready():
	_toastLabel.hide()
	
	setStartScreenVisible(true)
	setEndScreenVisible(false)
	setSidebarResultsVisible(false)
	setBestScoreVisible(false)
	setBestTimeVisible(false)
	
func setStartScreenVisible(visible):
	$StartGame.visible = visible
	$StartGame.set_process_input(visible)
	
func setEndScreenVisible(visible):
	$EndGame.visible = visible
	$EndGame.set_process_input(visible)
	
func setSidebarResultsVisible(resultsVisible):
	_scoreContainer.visible = true
	_comboContainer.visible = !resultsVisible
	_timeContainer.visible = resultsVisible
	_livesContainer.visible = !resultsVisible

func setScoreValue(value):
	if _scoreValue == value:
		return
	
	_scoreValueLabel.text = str(value)
	
	# punch the scale when the value increases
	if value > _scoreValue:
		_scoreTween = _punchValueScale(_scoreValueLabel, _scoreTween)
		
	_scoreValue = value

func setBestScoreVisible(visible):
	_scoreNewBestControl.visible = visible
	
func setComboValue(value):
	if _comboValue == value:
		return

	_comboValueLabel.text = str(value)
	
	# punch the scale when the value increases
	if value > _comboValue:
		_comboTween = _punchValueScale(_comboValueLabel, _comboTween)
		
	_comboValue = value

func setLives(lives : int):
	if _lives == lives:
		return
	
	var index := 0
	for child in _livesTextures.get_children():
		child.visible = index < lives
		index += 1
		
	_lives = lives
	
func setTime(seconds : int):
	if _seconds == seconds:
		return
	
	var minutes = floor(seconds / 60.0)
	var remainder = seconds % 60
	var string = "{0}:{1}".format({0: "%02d" % minutes, 1: "%02d" % remainder})
	_timeValueLabel.text = string
	
func setBestTimeVisible(visible):
	_timeNewBestControl.visible = visible
	
func playToast(toast : String):
	if _toastTween:
		_toastTween.kill()	
	
	_toastLabel.show()
	_toastLabel.text = toast
	_toastLabel.modulate = _toastColor

	_toastTween = self.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	var _propTweener = _toastTween.tween_property(
		_toastLabel, 
		'modulate:a', 
		0, 
		_toastDuration)
	var _callback = _toastTween.tween_callback(self, "_hideToast")
	
func _hideToast():
	_toastLabel.hide()
	
func _punchValueScale(valueLabel : Label, tween : SceneTreeTween) -> SceneTreeTween:
	if tween:
		tween.kill()
	
	valueLabel.rect_scale = Vector2.ONE * _valuePunchScale
	tween = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	var _propTweener = tween.tween_property(
		valueLabel, 
		'rect_scale', 
		Vector2.ONE, 
		_valuePunchDuration)
		
	return tween
	
