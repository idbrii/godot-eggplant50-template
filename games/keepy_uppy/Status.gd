extends HBoxContainer

func update_timer(secs):
	$TimeLabel.text = "%.2f" % secs
	
func on_touch_update(count):
	$TouchLabel.text = str(count)

func on_stick_combo_update(count):
	$StickComboLabel.text = str(count)

func on_head_combo_update(count):
	$HeadComboLabel.text = str(count)
