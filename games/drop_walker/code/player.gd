extends Node2D

export var gridworld_node : NodePath
export var move_duration := 0.5

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


func input_dir_to_direction(input_dir):
    if matches_grid_angle(input_dir, Vector2.UP):
        return $Direction/North
    if matches_grid_angle(input_dir, Vector2.RIGHT):
        return $Direction/East
    if matches_grid_angle(input_dir, Vector2.DOWN):
        return $Direction/South
    if matches_grid_angle(input_dir, Vector2.LEFT):
        return $Direction/West
    printt("input_dir_to_direction: failed to find a match.")
    return self
        

func input_dir_to_position(input_dir):
    var marker = input_dir_to_direction(input_dir)
    #~ printt("Going to", marker)
    return marker.global_position

func _process(_dt: float):
    var input = get_input()
    if input.move.length_squared() > 0.3*0.3:
        #~ printt("Move request:", input.move)
        block_input = true

        var dest = input_dir_to_position(input.move)

        var tween := create_tween()
        var t := tween.tween_property(self, "global_position", dest, move_duration)
        t = t.from_current()
        t = t.set_ease(Tween.EASE_IN_OUT)
        t = t.set_trans(Tween.TRANS_SINE)

        #~ yield(get_tree().create_timer(move_duration * 0.9), "timeout")
        yield(tween, "finished")
        block_input = false
