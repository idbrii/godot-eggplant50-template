extends Area2D

signal shape_harvested(shape)

enum PlotState {
	EMPTY,
	SEEDED,
	SMALL,
	MEDIUM,
	LARGE,
	ROTTEN,
	FALLOW
}

var state

func _ready() -> void:
	state = PlotState.EMPTY
	
func can_plant():
	return state == PlotState.EMPTY

func can_harvest():
	return state > PlotState.SEEDED and state < PlotState.FALLOW

func add_seed():
	if has_node('Seed') or state == PlotState.FALLOW:
		return
	var seed_node : Sprite = Sprite.new()
	seed_node.texture = load('res://games/polygonal_pasture/assets/triangle-seed.png')
	seed_node.name = 'Seed'
	add_child(seed_node)
	state = PlotState.SEEDED
	grow_seed()

func grow_seed():
	while state < PlotState.ROTTEN:
		yield(get_tree().create_timer(2.0+randf()), "timeout")
		if state == PlotState.FALLOW:
			return
		else:
			_grow_shape()

func _grow_shape():
	var seed_node = get_node('Seed')
	match state:
		PlotState.SEEDED:
			seed_node.texture = load('res://games/polygonal_pasture/assets/triangle-small.png')
			state = PlotState.SMALL
		PlotState.SMALL:
			seed_node.texture = load('res://games/polygonal_pasture/assets/triangle-medium.png')
			state = PlotState.MEDIUM
		PlotState.MEDIUM:
			seed_node.texture = load('res://games/polygonal_pasture/assets/triangle-large.png')
			state = PlotState.LARGE
		PlotState.LARGE:
			seed_node.texture = load('res://games/polygonal_pasture/assets/triangle-rotten.png')
			state = PlotState.ROTTEN

const TWEEN_DURATION = 0.5
func harvest_shape():
	var seed_node : Sprite = get_node('Seed')
	if !can_harvest():
		return
	
	var orig_state = state
	# Change now so nothing can be replanted (yet)
	state = PlotState.FALLOW
	
	var go_up = get_tree().create_tween()
	go_up.tween_property(seed_node, 'position', Vector2(seed_node.position.x, seed_node.position.y - 24), TWEEN_DURATION)
	go_up.set_ease(Tween.EASE_IN)
	var fade_out = get_tree().create_tween()
	fade_out.tween_property(seed_node, 'modulate', Color('#00ffffff'), TWEEN_DURATION)
	
	yield(fade_out, 'finished')

	if orig_state == PlotState.ROTTEN:
		return

	# This is _hideous_
	var path_parts = seed_node.texture.resource_path.split('/')
	var shape_name = path_parts[path_parts.size()-1].rstrip('.png')
	emit_signal('shape_harvested', shape_name)
