extends Viewport

func _ready():
	var parent = get_parent()
	var parentWorld = parent.get_world_2d()
	self.world_2d = parentWorld
	pass
