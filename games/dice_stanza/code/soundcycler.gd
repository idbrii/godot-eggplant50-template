extends Node

const SoundPool = preload("res://games/dice_stanza/code/soundpool.gd")

export(Array, Resource) var sounds = []

onready var _audio_player := $"../AudioPlayer" as SoundPool
onready var _sound_bag := []


var _last_source

func play():
	if _sound_bag.empty():
		_sound_bag = sounds.duplicate()
		_sound_bag.shuffle()
		
	var sound = _sound_bag.pop_back()
	# TODO: Should clear _last_source when the stream finishes.
	_last_source = _audio_player.play(sound)

func stop():
	if _last_source:
		_last_source.stop()
