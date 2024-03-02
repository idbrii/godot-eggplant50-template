extends ColorRect

const Types = preload("res://games/Arkaruga/Scripts/Arkaruga-Types.gd")

export var _flashColor : Color = Color.white
export var _flashStrength : float = .5
export var _flashDuration : float = .25
export var _blueBgColor : Color
export var _greenBgColor : Color

var _targetColor : Color
var _flashRoutine

func _process(delta):
	if _flashRoutine != null and _flashRoutine.is_valid():
		_flashRoutine = _flashRoutine.resume(delta)

func onActiveColorChanged(color: int):
	match color:
		Types.ElementColor.BLUE:
			_targetColor = _blueBgColor
		Types.ElementColor.GREEN:
			_targetColor = _greenBgColor
	
	_flashRoutine = _flashCoroutine()
			
func _flashCoroutine():
	var flashStartColor = lerp(_targetColor, _flashColor, _flashStrength)
	color = flashStartColor
	var t = 0.0
	while t < 1:
		var delta = yield()
		t += delta / _flashDuration
		color = lerp(flashStartColor, _targetColor, t)
	
	yield()
	color = _targetColor
	
