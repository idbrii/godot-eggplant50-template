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
	set_world_layer(current_layer, true)


func set_world_layer(index, snap):
	var layer = gridworlds[index]
	var dest = layer.global_position + camera_offset
	layer.attach_player_to_world(player)
	if snap:
		camera.global_position = dest
	else:
		var tween := create_tween()
		# TODO: How can I make this camera pan slower, but prevent game over until it's done?
		var t := tween.tween_property(camera, "global_position", dest, player.fall_duration)
		t = t.from_current()
		t = t.set_ease(Tween.EASE_IN_OUT)
		t = t.set_trans(Tween.TRANS_SINE)

		player.fall_to_layer(layer)

		yield(tween, "finished")
		player.done_falling()


func _on_fall_through_hole():
	current_layer += 1
	if current_layer < gridworlds.size():
		set_world_layer(current_layer, false)
	else:
		$UI/gameover.visible = true

