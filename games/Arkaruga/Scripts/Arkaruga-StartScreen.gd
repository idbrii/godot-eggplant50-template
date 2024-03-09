extends CanvasItem
	
onready var _manager : Node2D = get_tree().get_nodes_in_group("Manager")[0]
	
func _input(event):
	if event.is_action_pressed("action1"):
		if _manager:
			_manager.startGame()
