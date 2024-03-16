extends CanvasLayer
# Fancy scene transitioner. Add to your scene to fade in.
# https://www.gdquest.com/tutorial/godot/2d/scene-transition-rect/

onready var _anim_player := get_node("%AnimationPlayer")


func fade_transition_to(next_scene : PackedScene):
	# Plays the Fade animation and wait until it finishes
	_anim_player.play("fade")
	yield(_anim_player, "animation_finished")

	transition_to(get_tree(), next_scene)
	queue_free()


func transition_to_new_game(next_scene : PackedScene):
	# Plays the Fade animation and wait until it finishes
	_anim_player.play("fade")
	yield(_anim_player, "animation_finished")

	transition_to(get_tree(), next_scene)
	yield(get_tree(), "idle_frame")
	$PressToContinue.start_waiting()


static func transition_to(tree : SceneTree, next_scene : PackedScene):
	var result = tree.change_scene_to(next_scene)
	if result != OK:
		printt("Failed to transition to scene.", result)


func show_game_def(gamedef):
	$"%InputDisplay".set_game_def(gamedef)
	$"%InputDisplay".visible = true
