extends CanvasItem

export (float) var halflife = 1.0
export (bool) var startVisible = true

func _ready():
	visible = startVisible
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = false
	var _connection = timer.connect("timeout", self, "_flipVisible")
	timer.start(halflife)

func _flipVisible():
	visible = !visible
