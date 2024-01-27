extends HBoxContainer

func on_time_update():
	pass
	
func on_touch_update(count):
	$TouchLabel.text = str(count)

func on_stick_combo_update(count):
	$StickComboLabel.text = str(count)

func on_head_combo_update(count):
	$HeadComboLabel.text = str(count)
