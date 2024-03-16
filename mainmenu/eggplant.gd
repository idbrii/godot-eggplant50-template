extends Node

signal input_device_changed(name, icons);
signal restart_game()

const DeviceIcons = preload("res://shared/input/device_icons.gd")
const transition_scene = preload("res://mainmenu/scene_transition.tscn")

const device_icons_map = {
	# These are all DeviceIcons.
	keyboard = preload("res://shared/input/icon_keyboard.tres"),
	nintendo = preload("res://shared/input/icon_nintendo.tres"),
	playstation = preload("res://shared/input/icon_playstation.tres"),
	xbox = preload("res://shared/input/icon_xbox.tres"),
}

var last_played_scene : PackedScene
var current_game : GameDef
var _current_device := ""
var _last_input_joy := 0

var _music_player : AudioStreamPlayer
var muted_volume := -80.0
var music_fader : SceneTreeTween


func _ready():
	# To toggle fullscreen while paused.
	pause_mode = PAUSE_MODE_PROCESS
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	_music_player.volume_db = muted_volume
	add_child(_music_player)


func _input(event: InputEvent):
	# Toggle fullscreen with Alt-Enter
	if Input.is_action_just_pressed("toggle_fullscreen"):
		get_tree().set_input_as_handled()
		OS.window_fullscreen = !OS.window_fullscreen
	else:
		var prev_device = _current_device
		_check_device(event)
		_current_device = _compute_input_device()
		if prev_device != _current_device:
			self.emit_signal("input_device_changed", _current_device, get_input_icons())


func start_game(gamedef: GameDef = null):
	var transitioner = transition_to(gamedef.initial_scene, true)
	current_game = gamedef
	if gamedef:
		transitioner.show_game_def(gamedef)
		if gamedef.music:
			music_fade_in(gamedef.music, gamedef.music_volume)


func music_fade_in(music: AudioStream, volume_db: float):
	_music_player.stream = music
	_music_player.playing = true
	if music_fader:
		music_fader.stop()
	music_fader = create_tween()
	var t := music_fader.tween_property(_music_player, "volume_db", volume_db, 1)
	t = t.from_current()
	t = t.set_ease(Tween.EASE_IN)
	t = t.set_trans(Tween.TRANS_CIRC)
	return music_fader


func music_fade_out():
	if music_fader:
		music_fader.stop()
	music_fader = create_tween()
	var t := music_fader.tween_property(_music_player, "volume_db", muted_volume, 2)
	t = t.from_current()
	t = t.set_ease(Tween.EASE_IN)
	t = t.set_trans(Tween.TRANS_CIRC)
	return music_fader


func transition_to(next_scene: PackedScene, starting_game := false):
	assert(next_scene, "Need a scene to transition to.")
	last_played_scene = next_scene
	var transitioner = transition_scene.instance()
	add_child(transitioner)
	if starting_game:
		transitioner.transition_to_new_game(next_scene)
	else:
		transitioner.fade_transition_to(next_scene)
	return transitioner


func restart_scene():
	emit_signal("restart_game")
	transition_to(last_played_scene)


func return_to_menu():
	music_fade_out()
	current_game = null
	printt("Returning to menu...")
	transition_to(preload("res://mainmenu/mainmenu.tscn"))


func get_input_icons() -> DeviceIcons:
	var name = _compute_input_device()
	return device_icons_map[name] as DeviceIcons


func _check_device(event):
	var is_gamepad_device = event is InputEventJoypadButton
	var want_gamepad = is_gamepad_device
	var is_mouse_drift = event is InputEventMouseMotion and event.speed.length_squared() < 3000
	if event is InputEventJoypadMotion:
		is_gamepad_device = true
		# Big deadzone for auto switching visuals.
		want_gamepad = event.axis_value > 0.4
	if want_gamepad and Input.is_joy_known(event.device):
		_last_input_joy = event.device
	elif not is_gamepad_device and not is_mouse_drift:
		# Only disable gamepad if we definitely didn't receive input from a gamepad.
		_last_input_joy = -1


func _compute_input_device() -> String:
	if _last_input_joy >= 0 && Input.is_joy_known(_last_input_joy):
		var name = Input.get_joy_name(_last_input_joy)
		var appearance = get_simplified_device_name(name)
		#~ printt("Detected", name, "as", appearance)
		return appearance
	return "keyboard"


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
