extends ColorRect

const Types = preload("res://games/Arkaruga/Scripts/Arkaruga-Types.gd")

export var _colorChangedFlashColor : Color = Color.white
export var _colorChangedFlashStrength : float = .1
export var _colorChangedFlashDuration : float = .25

export var _damagedFlashColor : Color = Color.white

export var _blueBgColor : Color
export var _greenBgColor : Color

var _backgroundColor : Color
var _flashRoutine

func _process(delta):
	if _flashRoutine != null and _flashRoutine.is_valid():
		_flashRoutine = _flashRoutine.resume(delta)

func onActiveColorChanged(color: int):
	match color:
		Types.ElementColor.BLUE:
			_backgroundColor = _blueBgColor
		Types.ElementColor.GREEN:
			_backgroundColor = _greenBgColor
	
	_flashRoutine = _flashCoroutine(_colorChangedFlashColor, _colorChangedFlashStrength, _colorChangedFlashDuration)
	
func onDamaged(strength : float, duration : float):
	_flashRoutine = _flashCoroutine(_damagedFlashColor, strength, duration)

func _flashCoroutine(flashColor : Color, strength : float, duration : float):
	if duration > 0:
		var flashStartColor = lerp(_backgroundColor, flashColor, strength)
		color = flashStartColor
		var t = 0.0
		while t < 1:
			var delta = yield()
			t += delta / duration
			color = lerp(flashStartColor, _backgroundColor, t)
		
		yield()
	color = _backgroundColor
	
