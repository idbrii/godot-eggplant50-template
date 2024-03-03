extends Node2D

const Validate = preload("res://games/dice_stanza/code/util/validate.gd")

export var player_node : NodePath
onready var player := get_node_or_null(player_node) as Node2D

var current_layer := 0

onready var gridworlds := [
	$layer0/Grid_Ground,
	$layer1/Grid_Ground,
	$layer2/Grid_Ground,
]

onready var camera := $Camera2D as Camera2D
onready var camera_offset : Vector2 = camera.global_position - gridworlds[0].global_position


func _ready():
	Validate.ok(player.connect("fall_through_hole", self, "_on_fall_through_hole"))
	Validate.ok(player.connect("player_moved", self, "_on_player_moved"))
	set_world_layer(current_layer, true)

	# Adjust z index so player looks like they fall through holes and appear behind world.
	var z = gridworlds[0].z_index
	for layer in gridworlds:
		var root = layer.get_parent()
		root.z_index = z
		z -= 1


func set_world_layer(index, snap):
	var layer = gridworlds[index]
	var camera_dest = layer.global_position + camera_offset
	var player_pos = player.global_position
	var player_dest = layer.attach_player_to_world(player)
	if snap:
		camera.global_position = camera_dest
		player.global_position = player_dest
	else:
		var tween := create_tween()

		var t := tween.tween_property(camera, "global_position", camera_dest, player.drop_duration * 2)
		#~ var t := tween.tween_property(camera, "zoom", camera.zoom * 3, player.drop_duration * 2)  # Debug: see more world instead of moving
		t = t.from_current()
		t = t.set_ease(Tween.EASE_IN_OUT)
		t = t.set_trans(Tween.TRANS_SINE)

		player.global_position = player_pos
		player.fall_to_layer(layer, player_dest)

		yield(tween, "finished")
		player.done_falling()


func _on_fall_through_hole():
	current_layer += 1
	if current_layer < gridworlds.size():
		set_world_layer(current_layer, false)
	else:
		$UI/gameover.visible = true


func _on_player_moved(_player, dest_pos, delta):
	printt("Player moved:", dest_pos, delta)
	for layer in gridworlds:
		printt("layer:", layer, layer.snap_global_to_cell(dest_pos))
		
