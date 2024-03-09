tool
extends Control

const PathEdit = preload("res://addons/colorful-palette-swap/code/util/pathedit.gd")

export var label := "Path"
export var path_tooltip := "A file path."
export(PathEdit.PathType) var path_type := PathEdit.PathType.EXISTING_FILE


func _ready():
	$Label.text = label
	$PathValue.path_type = path_type
	$Label.hint_tooltip = path_tooltip
	$PathValue.hint_tooltip = path_tooltip
	$PickFileButton.connect("pressed", self, "_on_pick_file_button")


func _on_pick_file_button():
	var popup := EditorFileDialog.new()
	popup.disable_overwrite_warning = false
	popup.current_file = $PathValue.get_path()

	match $PathValue.path_type:
		PathEdit.PathType.EXISTING_DIRECTORY, PathEdit.PathType.NEW_DIRECTORY:
			popup.mode = EditorFileDialog.MODE_OPEN_DIR
			popup.display_mode = EditorFileDialog.DISPLAY_LIST
		PathEdit.PathType.EXISTING_FILE:
			popup.mode = EditorFileDialog.MODE_OPEN_FILE
			popup.display_mode = EditorFileDialog.DISPLAY_THUMBNAILS
		PathEdit.PathType.NEW_FILE:
			popup.mode = EditorFileDialog.MODE_SAVE_FILE
			popup.display_mode = EditorFileDialog.DISPLAY_THUMBNAILS

	add_child(popup)
	popup.connect("dir_selected", self, "_on_path_selected")
	popup.connect("file_selected", self, "_on_path_selected")
	popup.popup_centered_minsize(Vector2(1500, 900))


func _on_path_selected(path):
	# Note: popup.current_* aren't valid to fetch and sometimes contain
	# multiple concatenated paths.
	set_path_and_validate(path)


func get_path():
	return $PathValue.get_path()

func is_valid():
	return $PathValue.is_valid()

func set_path_and_validate(path):
	$PathValue.set_path_and_validate(path)
