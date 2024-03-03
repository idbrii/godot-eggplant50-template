extends TextureRect

export(String) var input := "primary"

func _ready():
	Eggplant.connect("input_device_changed", self, "_on_input_device_changed")
	_on_input_device_changed("", Eggplant.get_input_icons())

func _on_visibility_changed():
	if visible:
		_on_input_device_changed("", Eggplant.get_input_icons())

func _on_input_device_changed(_new_device, icons):
	if input in icons:
		self.texture = icons.get(input)

