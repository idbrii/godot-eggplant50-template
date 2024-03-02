tool
extends LineEdit

signal validity_changed(new_valid)
signal path_changed(new_path)

enum PathType {
	EXISTING_DIRECTORY,
	EXISTING_FILE,
	NEW_DIRECTORY,
	NEW_FILE,
}
export(PathType) var path_type := PathType.EXISTING_FILE

var _is_valid := false
var _warning : ColorRect

var _dir := Directory.new()


func _ready():
	_dir.open("res://")
	self.connect("text_changed", self, "_on_text_changed")
	_warning = ColorRect.new()
	_warning.color = Color.red
	_warning.color.a = 0.07
	_warning.set_anchors_and_margins_preset(PRESET_WIDE)
	_warning.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_warning)
	if self.text.empty():
		self.text = "res://"


func _looks_like_path(path: String):
	return path.begins_with("res://")


func _looks_like_file(path: String):
	return _looks_like_path(path) and path.rfind("/") < path.rfind(".")


func _looks_like_dir(path: String):
	return _looks_like_path(path)


func _on_text_changed(new_text):
	var old_valid = _is_valid
	match path_type:
		PathType.EXISTING_DIRECTORY:
			_is_valid = _dir.dir_exists(text)
		PathType.EXISTING_FILE:
			_is_valid = _dir.file_exists(text)
		PathType.NEW_DIRECTORY, PathType.NEW_FILE:
			_is_valid = _looks_like_path(text)
		_:
			printt("Invalid PathType:", path_type)
			_is_valid = false

	_warning.visible = not _is_valid

	if old_valid != _is_valid:
		emit_signal("validity_changed", _is_valid)

	self.emit_signal("path_changed", self.get_path())


func get_path():
	var path = text
	match path_type:
		PathType.EXISTING_DIRECTORY, PathType.NEW_DIRECTORY:
			if not path.ends_with("/"):
				path += "/"
	return path


func is_valid():
	return _is_valid


# Assigning to text or calling set_text externally doesn't trigger
# text_changed, so use this to ensure validation updates.
func set_path_and_validate(new_path):
	self.text = new_path
	# Assignment doesn't always trigger text_changed, so trigger manually.
	self.emit_signal("text_changed", self.text)
