extends Node

const Random = preload("res://games/dice_stanza/code/util/random.gd")


static func pick_tuning():
	var tuning_sets = [
		{
			time_limit = 20,
			player_rolls = 6,
			roll_pattern = {
				# Player roll number: dice count
				1: 3,
				4: 3,
			},
		},
		{
			time_limit = 30,
			player_rolls = 6,
			roll_pattern = {
				# Player roll number: dice count
				1: 3,
				4: 1,
				5: 2,
			},
		},
		{
			time_limit = 20,
			player_rolls = 4,
			roll_pattern = {
				# Player roll number: dice count
				1: 2,
				3: 1,
				4: 1,
			},
		},
	]

	var t = Random.choose_value(tuning_sets)
	#~ t.time_limit = 2  # CHEAT: Fast turns for debugging.
	return t

