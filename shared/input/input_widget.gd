extends Control

var devices = {
	keyboard = preload("res://shared/input/icon_keyboard.tres"),
	nintendo = preload("res://shared/input/icon_nintendo.tres"),
	playstation = preload("res://shared/input/icon_playstation.tres"),
	xbox = preload("res://shared/input/icon_xbox.tres"),
}

var current_device = ""
var last_input_joy = 0


func set_game_def(def):
	$"%Actions/primary/Label".text = _get_label(def.input_primary_action, "Primary")
	$"%Actions/secondary/Label".text = _get_label(def.input_secondary_action, "Secondary")
	$"%pause/Label".text = _get_label(def.input_pause, "Pause")
	$move_omni/Label.text = _get_label(def.input_directions, "Movement")
	$move_cardinal/Label.text = $move_omni/Label.text


func _get_label(label, default):
	if label and label.length() > 0:
		return label
	return default


func _input(event):
	var is_gamepad_device = event is InputEventJoypadButton
	var want_gamepad = is_gamepad_device
	if event is InputEventJoypadMotion:
		is_gamepad_device = true
		# Big deadzone for auto switching visuals.
		want_gamepad = event.axis_value > 0.4
	if want_gamepad and Input.is_joy_known(event.device):
		last_input_joy = event.device
	elif not is_gamepad_device:
		# Only disable gamepad if we definitely didn't receive input from a gamepad.
		last_input_joy = -1


func get_device():
	if Input.is_joy_known(last_input_joy):
		var name = Input.get_joy_name(last_input_joy)
		var appearance = get_simplified_device_name(name)
		#~ printt("Detected", name, "as", appearance)
		return appearance
	return "keyboard"


func _process(_dt):
	var new_device = get_device()
	if new_device != current_device:
		current_device = new_device
		var icons = devices[current_device]
		$"%Actions/primary/Icon".texture = icons.primary
		$"%Actions/secondary/Icon".texture = icons.secondary
		$"%pause/Icon".texture = icons.pause
		var has_omni = icons.move_omni != null
		$move_omni.visible = has_omni
		$move_cardinal.visible = not has_omni
		if icons.move_omni:
			$move_omni/Icon.texture = icons.move_omni
		else:
			$move_cardinal/upper/up.texture = icons.move_up
			$move_cardinal/lower/left.texture = icons.move_left
			$move_cardinal/lower/down.texture = icons.move_down
			$move_cardinal/lower/right.texture = icons.move_right



# https://github.com/nathanhoad/godot_input_helper/blob/70d6513d3ba3dce463ed12cdd412e451aac95975/addons/input_helper/input_helper.gd#L61C1-L79C25
func get_simplified_device_name(raw_name: String) -> String:
	match raw_name:
		"XInput Gamepad", "Xbox Series Controller", "Xbox 360 Controller", "Xbox One Controller":
					return "xbox"

		"Sony DualSense", "PS5 Controller", "PS4 Controller", "Nacon Revolution Unlimited Pro Controller":
					return "playstation"

		"Switch":
			return "nintendo"
		"Joy-Con (L)":
			return "nintendo"
		"Joy-Con (R)":
			return "nintendo"

		_:
			return "xbox"
