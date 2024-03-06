extends Node2D

var detailType = 'plates'


func plates_entered(area):
	$PlatesBorder.visible = true


func plates_exited(area):
	$PlatesBorder.visible = false
