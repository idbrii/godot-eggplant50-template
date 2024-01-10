extends Camera2D


export var target_node : NodePath
export var max_player_offset_from_center := 75.0
export var prevent_vertical_movement := false

onready var _target = get_node_or_null(target_node)


func _process(_delta):
	if _target:
		# Lots of potential improvement for camera logic. For inspiration see:
		# https://www.gamedeveloper.com/design/scroll-back-the-theory-and-practice-of-cameras-in-side-scrollers
		var orig_y = position.y
		var delta = position - _target.position
		delta = delta.limit_length(max_player_offset_from_center)
		position = _target.position + delta

		if prevent_vertical_movement:
			position.y = orig_y

	else:
		print("FollowCamera doesn't have a target")
		_grab_target()


func _grab_target():
	var players = get_tree().get_nodes_in_group("Player")
	if players != null: 
		_target = players[0] #because get_nodes_in_group returns an array even if it's an array of size 1

