extends CanvasLayer

export (NodePath) var viewportPath

func _ready():
	var viewportNode = get_node(viewportPath)
	if viewportNode != null:
		custom_viewport = viewportNode	
	
	pass
