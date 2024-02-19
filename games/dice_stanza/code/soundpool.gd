extends Node2D
# Based on: https://kidscancode.org/godot_recipes/3.x/audio/audio_manager/

const Validate = preload("res://games/dice_stanza/code/util/validate.gd")

export var num_streams := 8

var _pool = []
var _used = []

onready var template := $TemplateAudioPlayer


func _ready():
	assert(template, "Need a TemplateAudioPlayer as the basis for our AudioStreamPlayer2D.")
	# Create the pool of AudioStreamPlayer nodes.
	for i in num_streams:
		var p := template.duplicate()
		add_child(p)
		_pool.append(p)
		Validate.ok(p.connect("finished", self, "_on_stream_finished", [p]))


func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	_pool.append(stream)
	_used.erase(stream)


# Play a sound on an pooled stream. If no stream is available, it stops the
# oldest one. Returns the player so you can stop it.
#
# Call load() on a sound path to get an AudioStream.
func play(sound: AudioStream):
	var player : AudioStreamPlayer2D
	if _pool.empty():
		player = _used.pop_front()
	else:
		player = _pool.pop_back()
	player.stream = sound
	player.play()
	_used.append(player)
	return player

