extends Node2D

enum State {
	WAITING,
	SWAPPING,
	DROPPING,
}

export(AudioStreamSample) var music1 = preload('res://games/third_times_a_charm/gymnopedie_no1.wav')
export(AudioStreamSample) var music2 = preload('res://games/third_times_a_charm/gymnopedie_no2.wav')
export(AudioStreamSample) var music3 = preload('res://games/third_times_a_charm/gymnopedie_no3.wav')
export(AudioStreamSample) var music4 = preload('res://games/third_times_a_charm/noodle_cafe.wav')

var state : int
var grid : Array
var combo_count : int

func _ready() -> void:
	randomize()
	change_state('ready', State.WAITING)
	grid = []
	combo_count = 0

	for x in range(8):
		grid.append([])
		for y in range(4):
			grid[x].insert(y, make_shape(x, y))

	play_music()

func play_music():
	var tracks = [music1, music2, music3, music4]
	var pos = 0
	var ads : AudioStreamPlayer = $MusicPlayer
	while true:
		ads.stream = tracks[pos % 4]
		ads.play()
		yield(ads, 'finished')
		pos += 1

func make_shape(x, y):
	var s : Sprite = $Shapes.get_children()[randi() % $Shapes.get_child_count()].duplicate()
	s.global_position = Vector2(32+(x+1) * 64, 32+(y+1) * 64)
	s.scale = Vector2(0.9, 0.9)
	s.set_meta("shape", _sprite_to_name(s))
	s.set_meta("h_matched", false)
	s.set_meta("v_matched", false)
	$Grid.add_child(s)
	return s

func _sprite_to_name(s: Sprite):
	var rp = s.texture.resource_path
	if rp.match("*square*"):
		return "square"
	elif rp.match("*triangle*"):
		return "triangle"
	elif rp.match("*circle*"):
		return "circle"
	elif rp.match("*hexagon*"):
		return "hexagon"
	
func get_input() -> Dictionary:
	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return {
		"x": move.x,
		"y": move.y,
		"just_move": Input.is_action_just_pressed("action1"),
		"move": Input.is_action_pressed("action1"),
		"released_move": Input.is_action_just_released("action1"),
#		"change": Input.is_action_pressed("action2"),
#		"just_change": Input.is_action_just_pressed("action2"),#
	}

func debug(msg):
	print("[%d] %s" % [Time.get_ticks_msec(), msg])

func change_state(reason, new_state):
	debug("changing state because '%s' from %s to %s" % [reason, State.keys()[state], State.keys()[new_state]])
	state = new_state

func _process(_delta: float) -> void:
	var input = get_input()
	if state == State.WAITING and (input.x != 0 or input.y != 0):
		var cpos = $Cursor.global_position
		var move = Vector2(cpos.x, cpos.y)
		if input.x < 0 and cpos.x > 64:
			move.x = cpos.x - 64
		elif input.x > 0 and cpos.x < 512:
			move.x = cpos.x + 64
		elif input.y < 0 and cpos.y > 64:
			move.y = cpos.y - 64
		elif input.y > 0 and cpos.y < 256:
			move.y = cpos.y + 64
		
		if move != cpos:
			combo_count = 0
			update_combo_count(0)
			change_state('starting swap', State.SWAPPING)
			move_cursor(cpos, move)
			if input.move:
				try_swap(cpos, move)

	if state == State.WAITING:
		check_matches()

func update_score(score_delta):
	var new_score = int($UI/Status/Score.text) + score_delta
	$UI/Status/Score.text = str(new_score)

func update_matched(matched_delta):
	var new_matched = int($UI/Status/MatchedValue.text) + matched_delta
	$UI/Status/MatchedValue.text = str(new_matched)

func update_combo_count(combo_count):
	$UI/Status/ComboCount.text = '(x%d)' % combo_count

func update_combo_value(combo_delta):
	var new_count = int($UI/Status/ComboValue.text) + combo_delta
	$UI/Status/ComboValue.text = str(new_count)


const MATCH_SCORE = {
	3: 10,
	4: 20,
	5: 40
}

func check_matches():
	var matches = { h = [], v = [] }
	for x in range(grid.size()):
		for y in range(grid[x].size()):
			var shape = grid[x][y].get_meta('shape')

			# scan horizontally
			var i = x
			var h_matches = []
			while i < grid.size() and grid[i][y].get_meta('shape') == shape and not grid[i][y].get_meta('h_matched'):
				h_matches.append(grid[i][y])
				grid[i][y].set_meta('h_matched', true)
				i += 1
			if h_matches.size() >= 3:
				matches.h.append(h_matches)
			else:
				for s in h_matches:
					s.set_meta('h_matched', false)

			# scan horizontally
			var j = y
			var v_matches = []
			while j < grid[x].size() and grid[x][j].get_meta('shape') == shape and not grid[x][j].get_meta('v_matched'):
				v_matches.append(grid[x][j])
				grid[x][j].set_meta('v_matched', true)
				j += 1
			if v_matches.size() >= 3:
				matches.v.append(v_matches)
			else:
				for s in v_matches:
					s.set_meta('v_matched', false)

	if not matches.h.empty() or not matches.v.empty():
		change_state('new drops', State.DROPPING)

		var match_count = 0
		var score = 0
		combo_count += 1
		for m in matches.h:
			var matched = m.size()
			match_count += matched
			var scored = MATCH_SCORE[matched] if matched in MATCH_SCORE else 1000 # Don't think it can be more than 5???
			score += combo_count * scored
			remove_match(m)

		for m in matches.v:
			var matched = m.size()
			match_count += matched
			var scored = MATCH_SCORE[matched] if matched in MATCH_SCORE else 1000 # Don't think it can be more than 5???
			score += combo_count * scored
			remove_match(m)

		yield(get_tree().create_timer(0.5), 'timeout')

		update_score(score)
		update_matched(match_count)
		update_combo_count(combo_count)
		if combo_count > 1:
			update_combo_value(1)
		fill_gaps(matches)

const SWELL_PERIOD = 0.25
const SHRINK_PERIOD = 0.2
func remove_match(matched_shapes):
	for s in matched_shapes:
		# Prevent trying to remove the same shape twice
		if s.has_meta('removing1'):
			continue
		var swell = get_tree().create_tween()
		swell.tween_property(
			s, "scale", Vector2(1.1, 1.1), SWELL_PERIOD
		)
		swell.set_ease(Tween.EASE_IN)
		s.set_meta('removing1', true)

	yield(get_tree().create_timer(SWELL_PERIOD), 'timeout')

	var pnodes = []
	for s in matched_shapes:
		if s.has_meta('removing2'):
			continue
		var p = $MatchParticles.duplicate()
		p.emitting = true
		p.global_position = s.global_position
		add_child(p)
		pnodes.append(p)
		var shrink = get_tree().create_tween()
		shrink.tween_property(
			s, "scale", Vector2.ZERO, SHRINK_PERIOD
		)
		shrink.set_ease(Tween.EASE_IN)
		s.set_meta('removing2', true)

	yield(get_tree().create_timer(1), 'timeout')
	for p in pnodes:
		p.queue_free()


func fill_gaps(matches):
	# Dedupe all shapes and annotate which are being filled in.
	var all_gaps = []
	for m in matches.h:
		for s in m:
			if not all_gaps.has(s):
				all_gaps.append(s)
				s.set_meta('filling', true)
	for m in matches.v:
		for s in m:
			if not all_gaps.has(s):
				all_gaps.append(s)
				s.set_meta('filling', true)

	var gap_counts = {}
	# Figure out where shapes need to be added once all gaps are considered
	for s in all_gaps:
		var grid_pos = shape_to_grid_pos(s)
		if grid_pos.x in gap_counts:
			gap_counts[grid_pos.x] += 1
		else:
			gap_counts[grid_pos.x] = 1

	# Move existing shapes down
	for row in grid:
		for s in row:
			var grid_pos = shape_to_grid_pos(s)
			if not s.has_meta('filling'):
				var move_count = 0
				var row_idx = grid_pos.y + 1
				while row_idx < grid[grid_pos.x].size():
					if grid[grid_pos.x][row_idx].has_meta('filling'):
						move_count += 1
					row_idx += 1
				if move_count > 0:
					slide_down(s, move_count)

	var highest_count = 0
	for idx in gap_counts.keys():
		highest_count = max(highest_count, gap_counts[idx])
		for n in gap_counts[idx]:
			var s = make_shape(idx, -n - 1)
			slide_down(s, gap_counts[idx])

	yield(get_tree().create_timer(0.2 + (MOVE_PERIOD * highest_count)), 'timeout')

	for s in all_gaps:
		s.queue_free()

	change_state('finished dropping', State.WAITING)

func slide_down(shape, move_count):
	var move_to = Vector2(shape.global_position.x, shape.global_position.y + (64 * move_count))
	var slide_tween = get_tree().create_tween()
	slide_tween.tween_property(
		shape, "global_position", move_to, MOVE_PERIOD*move_count
	)
	slide_tween.set_ease(Tween.EASE_OUT)

	yield(slide_tween, 'finished')

	var new_pos = shape_to_grid_pos(shape)
	grid[new_pos.x][new_pos.y] = shape

func shape_to_grid_pos(shape) -> Vector2:
	var pos = shape.global_position
	return Vector2(((pos.x-32) / 64) - 1, ((pos.y-32) / 64) - 1)

const MOVE_PERIOD = 0.2
func move_cursor(from, to):
	$Cursor/Tween.interpolate_property(
		$Cursor, 'global_position', from, to, MOVE_PERIOD, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)
	$Cursor/Tween.start()

	yield($Cursor/Tween, 'tween_completed')
	change_state('finished cursor move', State.WAITING)
	check_matches()

func try_swap(move_from: Vector2, move_to: Vector2):
	var from_x_idx = (move_from.x / 64) - 1
	var from_y_idx = (move_from.y / 64) - 1
	var to_x_idx = (move_to.x / 64) - 1
	var to_y_idx = (move_to.y / 64) - 1

	var from_shape = grid[from_x_idx][from_y_idx]
	var from_tween = get_tree().create_tween()
	from_tween.tween_property(
		from_shape, "global_position", Vector2(move_to.x+32,move_to.y+32), MOVE_PERIOD
	)
	from_tween.set_ease(Tween.EASE_IN_OUT)

	var to_shape = grid[to_x_idx][to_y_idx]
	var to_tween = get_tree().create_tween()
	to_tween.tween_property(
		to_shape, "global_position", Vector2(move_from.x+32,move_from.y+32), MOVE_PERIOD
	)
	to_tween.set_ease(Tween.EASE_IN_OUT)
	
	yield(to_tween, 'finished')
	
	grid[from_x_idx][from_y_idx] = to_shape
	grid[to_x_idx][to_y_idx]     = from_shape
