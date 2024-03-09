tool
extends Node
# Takes an image and generates a palette from its pixels, sorted by brightness.

signal process_complete(output_filepath)  # String

const EditorPathInput = preload("res://addons/colorful-palette-swap/panel/editor_path_input.gd")
const Validate = preload("res://addons/colorful-palette-swap/code/util/validate.gd")
const Widget = preload("res://addons/colorful-palette-swap/code/util/widget.gd")

enum FilterMethod { ALL, GREY_VALUE, HUE }

onready var source_image_path_node := $Paths/Input as EditorPathInput
onready var output_path_node := $Paths/Output as EditorPathInput
onready var filter_node := $Paths/Filter/Value as OptionButton


class ColorSort:
	static func grey(c: Color) -> float:
		return (c.r * 1.0 + c.g * 1.0 + c.b * 1.0) / 3.0


	static func sort_grey(a, b):
		# Sort by grey because I think that matches what swappable_palette.gd is expecting.
		return grey(a) < grey(b)

	static func sort_hue(a, b):
		if a.h == b.h:
			return a.v < b.v
		return a.h < b.h


static func find_largest_saturation(color_list):
	var max_color = color_list[0]
	for c in color_list:
		if c.s > max_color.s:
			max_color = c
	return max_color


func _ready():
	$Button.connect("pressed", self, "_button_pressed")
	Widget.setup_dropdown_from_enum(filter_node, FilterMethod)
	filter_node.clear()
	for k in FilterMethod.keys():
		filter_node.add_item(k.capitalize())


func _button_pressed():
	if not source_image_path_node.is_valid():
		$"%InvalidPathPopup".show_complaint("Input requires a png file.")
	elif not output_path_node.is_valid():
		$"%InvalidPathPopup".show_complaint("Output requires a png file.")
	else:
		extract_palette(
			source_image_path_node.get_path(), 
			output_path_node.get_path(),
			filter_node.selected
			)
		emit_signal("process_complete", output_path_node.get_path())


static func extract_palette(source_image_path: String, output_path: String, filter):
	var image := Image.new()
	Validate.ok(image.load(source_image_path))
	image.lock()

	var size = image.get_size()

	var colors := {}
	var hues := {}
	for x in size.x:
		for y in size.y:
			var c = image.get_pixel(x, y)
			colors[c] = c
			hues[c.h] = hues.get(c.h, [])
			hues[c.h].append(c)

	var color_list := []

	if hues.size() > 200 and filter == FilterMethod.ALL:
		# Too many colours to save all.
		filter = FilterMethod.GREY_VALUE

	match filter:
		FilterMethod.ALL:
			# Include all colours (pixel art).
			for k in colors:
				var c = colors[k]
				color_list.append(c)

		FilterMethod.GREY_VALUE:
			var greys := []
			for k in colors:
				var c = colors[k]
				greys.append(c)

			greys.sort_custom(ColorSort, "sort_grey")
			var last_grey := -1.0
			for c in greys:
				var g = ColorSort.grey(c)
				var delta = g - last_grey
				if delta > 0.1:
					color_list.append(c)
					last_grey = g

		FilterMethod.HUE:
			# Limit hues
			var last_hue := -1.0
			for h in hues:
				var delta = h - last_hue
				if delta > 0.005:
					var c = find_largest_saturation(hues[h])
					color_list.append(c)
					last_hue = h


	color_list.sort_custom(ColorSort, "sort_grey")

	create_palette(output_path, color_list)

	printt("finished extracting palette to:", output_path)


static func create_palette(file_path: String, colors: Array):
	var out := Image.new()
	var box_width := 1
	var size_x := colors.size() * box_width
	var size_y := box_width
	out.create(size_x, size_y, false, Image.FORMAT_RGB8)

	out.lock()
	var i := 0
	for c in colors:
		var box_offset := box_width * i
		for x in range(box_width):
			for y in range(size_y):
				out.set_pixel(box_offset + x, y, c)
		i += 1
	out.unlock()

	Validate.ok(out.save_png(file_path))




func _on_ExecuteButton_pressed():
	printt("_on_ExecuteButton_pressed", self)
	pass # Replace with function body.
