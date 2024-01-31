extends Node2D

signal plot_enter(plot)
signal plot_exit(plot)

var current_plot

func _ready() -> void:
	for x in range(4):
		for y in range(4):
			var plot = $Plot.duplicate()
			plot.connect('body_entered', self, 'plot_entered', [plot])
			plot.connect('body_exited', self, 'plot_left', [plot])
			plot.position = Vector2((x+1)*64,(y+1)*64)
			plot.get_node('Sprite').rotation_degrees = randi() % 360
			$PlotNodes.add_child(plot)

func plot_entered(body, plot):
#	print(body, ' entered ', plot)
	plot.get_node('Highlight').visible = true
	emit_signal('plot_enter', plot)

func plot_left(body, plot):
#	print(body, ' left ', plot)
	plot.get_node('Highlight').visible = false
	emit_signal('plot_exit', plot)
