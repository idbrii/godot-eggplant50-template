extends Node2D

func _ready() -> void:
	$Balloon.connect('touch_update', $UI/Status, 'on_touch_update')
	$LilRobo.connect('stick_combo_update', $UI/Status, 'on_stick_combo_update')
	$LilRobo.connect('head_combo_update', $UI/Status, 'on_head_combo_update')
