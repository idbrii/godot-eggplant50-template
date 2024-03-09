extends TextureRect
# From Jon Gill: https://discord.com/channels/690388280767807518/807007411977715743/1213700863915204648

enum InputIconName {
	# Match device_icons.gd
	PRIMARY,
	SECONDARY,
	PAUSE,
}

const Validate = preload("res://addons/colorful-palette-swap/code/util/validate.gd")

export(InputIconName) var input := InputIconName.PRIMARY


func _ready():
	Validate.ok(Eggplant.connect("input_device_changed", self, "_on_input_device_changed"))
	Validate.ok(self.connect("visibility_changed", self, "_on_visibility_changed"))
	_on_input_device_changed("", Eggplant.get_input_icons())


func _on_visibility_changed():
	if visible:
		_on_input_device_changed("", Eggplant.get_input_icons())


static func icon_name_to_key(id):
	match id:
		InputIconName.PRIMARY:
			return "primary"
		InputIconName.SECONDARY:
			return "secondary"
		InputIconName.PAUSE:
			return "pause"
	return null

func _on_input_device_changed(_current_device, icons):
	var key = icon_name_to_key(input)
	if key:
		self.texture = icons[key]
