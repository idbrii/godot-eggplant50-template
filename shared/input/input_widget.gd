extends Control

enum Theme { DarkOnLight, LightOnDark, }
export(Theme) var contrast_theme := Theme.LightOnDark


func set_game_def(def):
	_apply_label(def.input_primary_action, $"%Actions/primary/Label", $"%Actions/primary")
	_apply_label(def.input_secondary_action, $"%Actions/secondary/Label", $"%Actions/secondary")
	_apply_label(def.input_pause, $"%pause/Label", $"%pause")
	_apply_label(def.input_directions, $move/move_omni/Label, $move)
	_apply_label(def.input_directions, $move/move_cardinal/Label, $move)


static func ok(err):
	assert(err == OK)


func _ready():
	ok(Eggplant.connect("input_device_changed", self, "_on_input_device_changed"))
	ok(self.connect("visibility_changed", self, "_on_visibility_changed"))

	if contrast_theme == Theme.DarkOnLight:
		var c = Color("#372538")
		$"%Actions/primary/Label".add_color_override("font_color", c)
		$"%Actions/secondary/Label".add_color_override("font_color", c)
		$"%pause/Label".add_color_override("font_color", c)
		$move/move_omni/Label.add_color_override("font_color", c)
		$move/move_cardinal/Label.add_color_override("font_color", c)


func _apply_label(label, text_widget, root):
	root.visible = label and label.length() > 0
	if root.visible:
		text_widget.text = label


func _on_visibility_changed():
	if visible:
		_on_input_device_changed("", Eggplant.get_input_icons())


func _on_input_device_changed(_new_device, icons):
	$"%Actions/primary/Icon".texture = icons.primary
	$"%Actions/secondary/Icon".texture = icons.secondary
	$"%pause/Icon".texture = icons.pause
	var has_omni = icons.move_omni != null
	$move/move_omni.visible = has_omni
	$move/move_cardinal.visible = not has_omni
	if icons.move_omni:
		$move/move_omni/Icon.texture = icons.move_omni
	else:
		$move/move_cardinal/upper/up.texture = icons.move_up
		$move/move_cardinal/lower/left.texture = icons.move_left
		$move/move_cardinal/lower/down.texture = icons.move_down
		$move/move_cardinal/lower/right.texture = icons.move_right

