extends KinematicBody2D

func get_input() -> Dictionary:
	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return {
		"x": move.x,
		"y": move.y,
		"just_jump": Input.is_action_just_pressed("action1"),
		"jump": Input.is_action_pressed("action1"),
		"released_jump": Input.is_action_just_released("action1"),
		"walk": Input.is_action_pressed("action2"),
	}

func _process(_delta: float) -> void:
	var action = get_input()
	position.x += action.x
	position.y += action.y

	if action.just_jump:
		 handle_action()

func handle_action():
	for plot in plots_on:
		if plot.can_plant():
			plot.add_seed()
			return
		elif plot.can_harvest():
			plot.harvest_shape()
			return

var plots_on = []
func on_plot_enter(plot):
	if !plots_on.has(plot):
		plots_on.append(plot)

func on_plot_exit(plot):
	plots_on.erase(plot)
