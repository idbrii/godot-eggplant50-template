extends Node2D

signal fall_through_hole
signal player_moved(player, pos)

const GridWorld = preload("res://games/drop_walker/code/gridworld.gd")
const Namer = preload("res://games/drop_walker/code/util/namer.gd")

export var gridworld_node : NodePath
export var move_duration := 0.5

export var drop_duration := 1.0

var block_input := false
var tile_width := 64

onready var gridworld := get_node_or_null(gridworld_node) as TileMap
onready var player_visual = get_node("%PlayerVisual")


func get_input() -> Dictionary:
    if block_input:
        return {
            move = Vector2.ZERO,
            just_jump = false,
            jump = false,
            released_jump = false,
            walk = false,
            just_dash = false,
            hold_dash = false,
            released_dash = false,
        }
    var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    return {
        move = move,
        just_jump = Input.is_action_just_pressed("action1"),
        jump = Input.is_action_pressed("action1"),
        released_jump = Input.is_action_just_released("action1"),
        walk = false,  # Input.is_action_pressed("action2"),
        just_dash = Input.is_action_just_pressed("action2"),
        hold_dash = Input.is_action_pressed("action2"),
        released_dash = Input.is_action_just_released("action2"),
    }

func matches_grid_angle(input_dir, direction):
    var segment := TAU/4 * 0.99 * 0.5
    var a = input_dir.angle_to(direction)
    return abs(a) < segment


func input_dir_to_delta(input_dir):
    var delta = gridworld.cell_size / 2
    if matches_grid_angle(input_dir, Vector2.UP):
        delta *= -1
    elif matches_grid_angle(input_dir, Vector2.RIGHT):
        delta.y *= -1
    elif matches_grid_angle(input_dir, Vector2.DOWN):
        delta *= 1
    elif matches_grid_angle(input_dir, Vector2.LEFT):
        delta.x *= -1
    else:
        printt("input_dir_to_delta: failed to find a match.")
        delta = Vector2.ZERO
    return delta


func _process(_dt: float):
    var input = get_input()
    # Rotate input closer to iso projection to correctly interpret diagonal inputs.
    var iso_move = input.move.rotated(TAU * 1/10)
    if iso_move.length_squared() > 0.3*0.3:
        #~ printt("Move request:", iso_move)

        var delta = input_dir_to_delta(iso_move)
        var dest = delta + global_position
        var dest_tile = gridworld.get_world_cellv(dest)

        #~ printt('dest_tile', Namer.enum_as_string(GridWorld.GroundType, dest_tile), dest)
        #~ gridworld.set_world_cellv(dest, GridWorld.GroundType.SOLID)
        block_input = true
        var tween := create_tween()
        match dest_tile:
            GridWorld.GroundType.SOLID,GridWorld.GroundType.EMPTY:
                var t := tween.tween_property(self, "global_position", delta, move_duration)
                t = t.from_current()
                t = t.as_relative()
                t = t.set_ease(Tween.EASE_IN_OUT)
                t = t.set_trans(Tween.TRANS_SINE)

            _:
                var duration = move_duration * 0.1
                var current_pos = global_position
                var t := tween.tween_property(self, "global_position", delta * 0.1, duration)
                t = t.from_current()
                t = t.as_relative()
                t = t.set_ease(Tween.EASE_IN_OUT)
                t = t.set_trans(Tween.TRANS_SINE)
                t = tween.chain().tween_property(self, "global_position", current_pos, duration)
                t = t.from_current()
                t = t.set_ease(Tween.EASE_IN_OUT)
                t = t.set_trans(Tween.TRANS_SINE)

        yield(tween, "finished")

        # Uncomment to tune fall_to_layer by triggering every frame.
        #~ global_position += Vector2.UP * 500
        #~ fall_to_layer("layer", dest)

        block_input = false

        emit_signal("player_moved", self, dest, delta)

        if dest_tile == GridWorld.GroundType.EMPTY:
            emit_signal("fall_through_hole")


func fall_to_layer(layer, dest):
    printt("Player fall_to_layer", layer, "falling:", global_position, "->", dest)
    block_input = true
    var tween := create_tween()

    var fall_duration = drop_duration * 0.75
    var bounce_duration = drop_duration - fall_duration
    var fall_speed = dest.distance_to(global_position) / fall_duration
    var n_bounces = 2
    var bounce_height = fall_speed * bounce_duration / n_bounces * 0.5

    var t := tween.tween_property(self, "global_position", dest, fall_duration)
    t = t.from_current()
    t = t.set_ease(Tween.EASE_IN)
    t = t.set_trans(Tween.TRANS_CIRC)
    for i in range(n_bounces-1):
        bounce_duration *= 2
        var bounce_peak = dest + Vector2.UP * bounce_height / pow(2, i - 1)
        t = tween.chain().tween_property(self, "global_position", bounce_peak, bounce_duration * 0.5)
        t = t.from(dest)
        t = t.set_ease(Tween.EASE_OUT)
        t = t.set_trans(Tween.TRANS_SINE)
        t = tween.chain().tween_property(self, "global_position", dest, bounce_duration * 0.5)
        t = t.from(bounce_peak)
        t = t.set_ease(Tween.EASE_IN_OUT)
        t = t.set_trans(Tween.TRANS_CUBIC)

    yield(tween, "finished")
    printt("Player fall_to_layer. fell", global_position)
    # Don't restore block_input. We'll do that in done_falling when level is done transition.


func done_falling():
    block_input = false
    var dest_tile = gridworld.get_world_cellv(global_position)
    printt("Player done_falling. dest", global_position, dest_tile)
    if dest_tile == GridWorld.GroundType.EMPTY:
        yield(get_tree().create_timer(drop_duration * 0.1), "timeout")
        emit_signal("fall_through_hole")
