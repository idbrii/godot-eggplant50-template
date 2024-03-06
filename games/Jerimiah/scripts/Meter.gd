extends Node2D

var detailType = 'meter'
var timer: Timer

func _ready():
	timer = $Timer

func meter_entered(area):
	$Border.visible = true

func meter_exited(area):
	$Border.visible = false

func add_time(time):
	timer.start(timer.time_left + time)
