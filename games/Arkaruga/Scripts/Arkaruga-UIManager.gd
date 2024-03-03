extends CanvasLayer

export (Color) var _toastColor = Color.white
export (float) var _toastDuration = .9
export (float) var _valuePunchScale = 1.2
export (float) var _valuePunchDuration = .25

onready var _scoreValueLabel : Label = $Sidebar/Margins/VBoxContainer/ScoreValueControl/Label
onready var _comboValueLabel : Label = $Sidebar/Margins/VBoxContainer/ComboValueControl/Label
onready var _livesContainer : Control = $Sidebar/Margins/VBoxContainer/BallsContainer
onready var _toastLabel : Label = $Game/ToastLabel

var _scoreValue = -1
var _comboValue = -1
var _lives = -1
var _scoreTween : SceneTreeTween = null
var _comboTween : SceneTreeTween = null
var _toastTween : SceneTreeTween = null

func _ready():
	_toastLabel.hide()
	
func setStartScreenVisible(visible):
	 $StartGame.visible = visible
	 $StartGame.set_process_input(visible)

func setScoreValue(value):
	if _scoreValue == value:
		return
	
	_scoreValueLabel.text = str(value)
	
	# punch the scale when the value increases
	if value > _scoreValue:
		_scoreTween = _punchValueScale(_scoreValueLabel, _scoreTween)
		
	_scoreValue = value
	
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
	for child in _livesContainer.get_children():
		child.visible = index < lives
		index += 1
		
	_lives = lives
	
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
	
