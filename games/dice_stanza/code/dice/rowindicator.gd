extends Control

onready var result_label := get_node("%ResultLabel") as Label


func _ready():
	visible = false


func play_result(player, oppo) -> bool:
	visible = true
	var is_win = player > oppo
	if player == 0:
		result_label.text = "OVERFLOW"
	elif is_win:
		result_label.text = "WIN"
	else:
		result_label.text = "LOSE"
	return is_win


func play_overflow():
	visible = true
	result_label.text = "OVERFLOW"
