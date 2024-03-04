extends Node2D

var is_swapping = false
var grid = []

func _ready() -> void:
	for x in range(8):
		grid.append([])
		for y in range(4):
			var s : Sprite = $Shapes.get_children()[randi() % $Shapes.get_child_count()].duplicate()
			s.global_position = Vector2(32+(x+1) * 64, 32+(y+1) * 64)
			s.scale = Vector2(0.9, 0.9)
			s.set_meta("shape", _sprite_to_name(s))
			$Grid.add_child(s)
			
			grid[x].insert(y, s)

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

func _process(_delta: float) -> void:
	var input = get_input()
	if not is_swapping and (input.x != 0 or input.y != 0):
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
			is_swapping = true
			move_cursor(cpos, move)
#			print("move from ", (cpos.x/64), 'x', (cpos.y/64), " ", cpos, " to ", (move.x/64), 'x', (move.y/64), " ", move)
			if input.move:
				try_swap(cpos, move)

func check_matches():
	var matches = { h = [], v = [] }
	for x in range(grid.size()):
		for y in range(grid[x].size()):
			var shape = grid[x][y].get_meta('shape')

			# scan horizontally
			var i = x
			var h_matches = []
			while i < grid.size() and grid[i][y].get_meta('shape') == shape:
				h_matches.append(grid[i][y])
				i += 1
			if h_matches.size() >= 3:
				matches.h.append(h_matches)

			# scan horizontally
			var j = y
			var v_matches = []
			while j < grid[x].size() and grid[x][j].get_meta('shape') == shape:
				v_matches.append(grid[x][j])
				j += 1
			if v_matches.size() >= 3:
				matches.v.append(v_matches)

	for m in matches.h:
		remove_match(m)
	for m in matches.v:
		remove_match(m)

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

	for s in matched_shapes:
		if s.has_meta('removing2'):
			continue
		var shrink = get_tree().create_tween()
		shrink.tween_property(
			s, "scale", Vector2.ZERO, SHRINK_PERIOD
		)
		shrink.set_ease(Tween.EASE_IN)
		s.set_meta('removing2', true)
	yield(get_tree().create_timer(SHRINK_PERIOD), 'timeout')

func fill_gaps(matches):
	pass
const MOVE_PERIOD = 0.2
func move_cursor(from, to):
	$Cursor/Tween.interpolate_property(
		$Cursor, 'global_position', from, to, MOVE_PERIOD, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)
	$Cursor/Tween.start()

	yield($Cursor/Tween, 'tween_completed')
	is_swapping = false
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
