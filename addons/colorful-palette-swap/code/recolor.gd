tool
extends Node
# Changes all pixels matching the input to the output, but maintains alpha
# value. Useful to change appearance of simple images.


signal process_complete(output_filepath)  # String

const Validate = preload("res://addons/colorful-palette-swap/code/util/validate.gd")
const EditorPathInput = preload("res://addons/colorful-palette-swap/panel/editor_path_input.gd")
const sizeX = 100

onready var target_path_node := $Paths/Input as EditorPathInput
onready var image_preview := $Paths/ImagePreview as TextureRect
onready var palette_path_node := $Paths/Palette as EditorPathInput
onready var palette_preview := $Paths/PalettePreview as TextureRect



func _ready():
	$Button.connect("pressed", self, "_button_pressed")
	target_path_node.get_node("PathValue").connect("path_changed", self, "_on_imagepath_changed", [target_path_node, image_preview])
	palette_path_node.get_node("PathValue").connect("path_changed", self, "_on_imagepath_changed", [palette_path_node, palette_preview])
	_on_imagepath_changed("", target_path_node, image_preview)


func _on_imagepath_changed(_path, path_node, target_preview):
	if path_node.is_valid():
		target_preview.texture = load(path_node.get_path())
	else:
		target_preview.texture = null


func _button_pressed():
	var color_from = $Paths/FromColor/Value.color
	var color_to = $Paths/ToColor/Value.color
	if not target_path_node.is_valid():
		$"%InvalidPathPopup".show_complaint("Input requires an existing file.")
	else:
		var msg = recolor_image(
			target_path_node.get_path(),
			color_from,
			color_to)
		get_parent().get_node("Output").text = msg
		emit_signal("process_complete", target_path_node.get_path())


static func recolor_image(
		target_path: String,
		color_from: Color,
		color_to: Color
		):
	var image := Image.new()
	Validate.ok(image.load(target_path))
	image.lock()

	color_from.a = 0
	color_to.a = 0

	var change_count := 0

	for x in range(1, image.get_width()):
		for y in range(1, image.get_height()):
			var c = image.get_pixel(x, y)
			var a = c.a
			c.a = 0
			if c == color_from:
				change_count += 1
				c = color_to
				c.a = a
				image.set_pixel(x, y, c)

	image.unlock()
	Validate.ok(image.save_png(target_path))
	var msg = "Changed %s pixels." % change_count
	print("Recolor Image: ",msg)
	return msg

