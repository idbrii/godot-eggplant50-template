extends CanvasItem

export (float) var halflife = 1
export (float) var startVisible = true

func _ready():
	visible = startVisible
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.connect("timeout", self, "_flipVisible")
	timer.start(halflife)

func _flipVisible():
	visible = !visible
