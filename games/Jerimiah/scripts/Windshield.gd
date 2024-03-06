extends Node2D

export(String) var detailType

var enabled = true

func windshield_entered(area):
	if enabled:
		$HighlightBorder.visible = true


func windshield_exited(area):
	$HighlightBorder.visible = false
