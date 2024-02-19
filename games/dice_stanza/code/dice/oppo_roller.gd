extends Node

const DiceBlock = preload("res://games/dice_stanza/scenes/OppoDiceBlock.tscn")
const Random = preload("res://games/dice_stanza/code/util/random.gd")
const Validate = preload("res://games/dice_stanza/code/util/validate.gd")

export(float, 0, 500) var OFFSET := 40.0
export(int, 0, 10) var rounds := 5
export(float, 0, 10) var meter_anim_duration := 2.0


onready var win_meter := $"%WinMeter" as ProgressBar

onready var drop_spots = [
	$DropSpot/Top,
	$DropSpot/Middle,
	$DropSpot/Bottom,
]

onready var row_sensors = [
	$RowSensor/Top,
	$RowSensor/Middle,
	$RowSensor/Bottom,
]

onready var row_indicators = [
	$RowIndicator/Top,
	$RowIndicator/Middle,
	$RowIndicator/Bottom,
]

var roll_pattern = {
	# Player roll number: dice count
	1: 3,
	4: 3,
}

var drop_offsets = []
var past_blocks = []
var row_sums = []

func _ready():
	for __ in drop_spots:
		drop_offsets.append(0)
		row_sums.append(0)
	Validate.ok(Broadcast_idbrii.connect("player_rolled", self, "_on_player_rolled"))
	Validate.ok(Broadcast_idbrii.connect("time_expired", self, "_on_time_expired"))
	Validate.ok(Broadcast_idbrii.connect("start_round", self, "_on_start_round"))

	# Delay a frame for everyone else to register signal.
	yield(get_tree(), "idle_frame")
	Broadcast_idbrii.emit_signal("start_round")


# Uncomment to preview win state and debug UI.
#~ func _process(_dt):
#~ 	compute_results()


func sort_dice_count_asc(a, b):
	# Returns: should a come first
	return drop_spots[a].get_child_count() < drop_spots[b].get_child_count()


func _on_player_rolled(_value, total_rolls):
	var count = Broadcast_idbrii.tuning.roll_pattern.get(total_rolls)
	if count:
		var row_map = range(drop_spots.size())
		row_map.shuffle()  # if equal, they're randomized
		row_map.sort_custom(self, "sort_dice_count_asc")
		for i in range(count):
			var row = row_map[i]
			_roll_in_row(row)


func _roll_in_row(row):
	var block = roll()
	var spot = drop_spots[row]
	spot.add_child(block)
	block.position = Vector2.LEFT * drop_offsets[row]
	drop_offsets[row] += OFFSET
	row_sums[row] += block.value
	

func roll():
	var block = DiceBlock.instance()
	past_blocks.append(block)
	var v = Random.integer(1, 6)
	block.set_face_value(v)
	return block


func _on_time_expired():
	compute_results()


func compute_results():
	var player_sums = []
	for row in row_sensors.size():
		var sum := 0
		var sensor := row_sensors[row] as Area2D
		for block in sensor.get_overlapping_bodies():
			if not block.is_in_group("oppo"):
				sum += block.value
		player_sums.append(sum)

	var pop_sound = $"%EndgameDisplay/Sound/Pop"
	var thump_sound = $"%EndgameDisplay/Sound/Thump"
	for row in row_sums.size():
		var player = player_sums[row]
		if player == 0:
			row_indicators[row].play_overflow()
			# If player leaves a row empty, overflow dice into other rows to
			# make min/maxing harder.
			thump_sound.play()
			yield(get_tree().create_timer(0.5), "timeout")
			for r in row_sums.size():
				if r != row:
					_roll_in_row(r)
					pop_sound.play()
					yield(get_tree().create_timer(0.7), "timeout")

	var player_wins := 0
	for row in row_sums.size():
		var oppo = row_sums[row]
		var player = player_sums[row]
		var is_win = row_indicators[row].play_result(player, oppo)
		if is_win:
			player_wins += 1

	var player_won = player_wins >= 2
	var dt_sign: float = 1 if player_won else -1
	var dt := dt_sign / float(rounds)
	var meter_dest := dt + win_meter.value

	var sound
	if player_won:
		sound = $"%EndgameDisplay/Sound/GainGround"
	else:
		sound = $"%EndgameDisplay/Sound/LoseGround"
	sound.play()

	var tween := create_tween()
	var t := tween.tween_property(win_meter, "value", dt, meter_anim_duration)
	t = t.from_current()
	t = t.as_relative()
	t = t.set_ease(Tween.EASE_IN_OUT)
	t = t.set_trans(Tween.TRANS_SINE)
	yield(tween, "finished")

	sound.stop()

	if meter_dest <= 0:
		trigger_lose()
	elif meter_dest >= 1:
		trigger_win()
	else:
		Broadcast_idbrii.emit_signal("start_round")


func _on_start_round():
	reset_state()

func reset_state():
	for b in past_blocks:
		b.queue_free()
	past_blocks.clear()
	for row in row_sums.size():
		row_indicators[row].visible = false
		drop_offsets[row] = 0
		row_sums[row] = 0



func trigger_win():
	$"%EndgameDisplay".show_win()
	Broadcast_idbrii.emit_signal("game_over")

			
func trigger_lose():
	$"%EndgameDisplay".show_lose()
	Broadcast_idbrii.emit_signal("game_over")

