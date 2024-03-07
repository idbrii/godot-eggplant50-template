extends KinematicBody2D

signal seed_change(shape)

const PpShape = preload('res://games/polygonal_pasture/Shape.gd')

const SEED_SHAPES = [
	PpShape.ShapeName.TRIANGLE,
	PpShape.ShapeName.SQUARE,
	PpShape.ShapeName.HEXAGON
]

var current_shape : PpShape

func _ready():
	current_shape = PpShape.new()
	current_shape.shape_name = PpShape.ShapeName.TRIANGLE
	current_shape.shape_size = PpShape.ShapeSize.SEED

func get_input() -> Dictionary:
	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return {
		"x": move.x,
		"y": move.y,
		"just_plant": Input.is_action_just_pressed("action1"),
		"plant": Input.is_action_pressed("action1"),
		"released_plant": Input.is_action_just_released("action1"),
		"change": Input.is_action_pressed("action2"),
		"just_change": Input.is_action_just_pressed("action2"),
	}

func _process(_delta: float) -> void:
	var action = get_input()
	position.x += action.x
	position.y += action.y

	if action.just_plant:
		handle_plant()
	if action.just_change:
		handle_change()

func handle_plant():
	for plot in plots_on:
		if plot.can_plant():
			plot.add_seed(current_shape)
			return
		elif plot.can_harvest():
			plot.harvest_shape()
			return

func handle_change():
	var pos = SEED_SHAPES.find(current_shape.shape_name)
	if pos == SEED_SHAPES.back():
		current_shape.shape_name = SEED_SHAPES[0]
	else:
		current_shape.shape_name = SEED_SHAPES[pos + 1]
	emit_signal('seed_change', current_shape)

var plots_on = []
func on_plot_enter(plot):
	if !plots_on.has(plot):
		plots_on.append(plot)

func on_plot_exit(plot):
	plots_on.erase(plot)
