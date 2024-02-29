extends Node2D

signal fall_through_hole

const GridWorld = preload("res://games/drop_walker/code/gridworld.gd")
const Namer = preload("res://games/drop_walker/code/util/namer.gd")

export var gridworld_node : NodePath
export var move_duration := 0.5

export var fall_duration := 1.0
export var bounce_height := 1.0

var block_input := false
var tile_width := 64
var initial_offset : Vector2

onready var gridworld := get_node_or_null(gridworld_node) as TileMap
onready var player_visual = get_node("%PlayerVisual")


func _ready():
    initial_offset = gridworld.world_to_map(position)

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

        #~ printt('dest_tile', Namer.enum_as_string(GridWorld.GroundType, dest_tile))
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
        block_input = false

        if dest_tile == GridWorld.GroundType.EMPTY:
            emit_signal("fall_through_hole")


func fall_to_layer(layer):
    block_input = true
    var dest = layer.attach_player_to_world(self)
    var tween := create_tween()

    # TODO: This fall animation doesn't seem to work. We teleport there instead.
    var t := tween.tween_property(self, "global_position", dest, fall_duration * 0.80)
    t = t.from_current()
    t = t.set_ease(Tween.EASE_IN_OUT)
    t = t.set_trans(Tween.TRANS_SINE)
    t = tween.chain().tween_property(self, "global_position", dest + Vector2.UP * bounce_height, fall_duration * 0.1)
    t = t.from_current()
    t = t.set_ease(Tween.EASE_IN_OUT)
    t = t.set_trans(Tween.TRANS_SINE)
    t = tween.chain().tween_property(self, "global_position", dest + Vector2.UP * -bounce_height, fall_duration * 0.1)
    t = t.from_current()
    t = t.set_ease(Tween.EASE_IN_OUT)
    t = t.set_trans(Tween.TRANS_SINE)

    yield(tween, "finished")
    block_input = false


func done_falling():
    var dest_tile = gridworld.get_world_cellv(global_position)
    if dest_tile == GridWorld.GroundType.EMPTY:
        emit_signal("fall_through_hole")
