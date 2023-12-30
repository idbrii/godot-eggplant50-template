extends Camera2D


export var target_node : NodePath

onready var _target = get_node_or_null(target_node)


func _process(_delta):
	if _target:
		# Only follow x position because we're doing weird zooming.
		position.x = _target.position.x
	else:
		print("FollowCamera doesn't have a target")
		_grab_target()


func _grab_target():
	var players = get_tree().get_nodes_in_group("Player")
	if players != null: 
		_target = players[0] #because get_nodes_in_group returns an array even if it's an array of size 1

