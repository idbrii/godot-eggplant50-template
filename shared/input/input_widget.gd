extends Control


func set_game_def(def):
	$"%Actions/primary/Label".text = _get_label(def.input_primary_action, "Primary")
	$"%Actions/secondary/Label".text = _get_label(def.input_secondary_action, "Secondary")
	$"%pause/Label".text = _get_label(def.input_pause, "Pause")
	$move_omni/Label.text = _get_label(def.input_directions, "Movement")
	$move_cardinal/Label.text = $move_omni/Label.text


static func ok(err):
	assert(err == OK)


func _ready():
	ok(Eggplant.connect("input_device_changed", self, "_on_input_device_changed"))
	ok(self.connect("visibility_changed", self, "_on_visibility_changed"))


func _get_label(label, default):
	if label and label.length() > 0:
		return label
	return default


func _on_visibility_changed():
	if visible:
		_on_input_device_changed("", Eggplant.get_input_icons())


func _on_input_device_changed(_new_device, icons):
	$"%Actions/primary/Icon".texture = icons.primary
	$"%Actions/secondary/Icon".texture = icons.secondary
	$"%pause/Icon".texture = icons.pause
	var has_omni = icons.move_omni != null
	$move_omni.visible = has_omni
	$move_cardinal.visible = not has_omni
	if icons.move_omni:
		$move_omni/Icon.texture = icons.move_omni
	else:
		$move_cardinal/upper/up.texture = icons.move_up
		$move_cardinal/lower/left.texture = icons.move_left
		$move_cardinal/lower/down.texture = icons.move_down
		$move_cardinal/lower/right.texture = icons.move_right

