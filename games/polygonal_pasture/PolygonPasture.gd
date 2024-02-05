extends Node2D

func _ready() -> void:
	$Pasture.connect('plot_enter', $Farmer, 'on_plot_enter')
	$Pasture.connect('plot_exit',  $Farmer, 'on_plot_exit')
	$Pasture.connect('shape_gathered', $Basket, 'on_shape_gathered')
	$Basket.connect('shape_ready_to_collect', $Distribution, 'on_shape_ready_to_collect')
	$Farmer.connect('seed_change', $UI/Status, 'on_seed_change')
