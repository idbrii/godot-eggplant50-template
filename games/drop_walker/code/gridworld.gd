extends TileMap

const Container = preload("res://games/drop_walker/code/util/container.gd")


enum GroundType {
    EMPTY,
    SOLID,
    BORDER,
    GOAL,
}

var ground_to_tile = {
    GroundType.EMPTY: -1,
    GroundType.SOLID: 0,
    GroundType.BORDER: 19,
    GroundType.GOAL: 20,
}
var tile_to_ground = Container.invert_dict(ground_to_tile)


func _ready():
    var layer := get_parent() as Node
    var goals = get_tree().get_nodes_in_group("goal")
    for g in goals:
        if layer.is_a_parent_of(g):
            var pos = snap_global_to_cell(g.global_position)
            set_world_cellv(pos, GroundType.GOAL)
            g.global_position = center_global_pos_in_cell(pos)


# Returns a global position that's the bottom corner of a tile.
# https://www.reddit.com/r/godot/comments/fuejci/having_trouble_with_snapping_to_isometric_grid/fmcl07f/
func snap_global_to_cell(world_pos: Vector2) -> Vector2:
    return to_global(map_to_world(world_to_map(to_local(world_pos))))


func global_to_cell_pos(world_pos: Vector2) -> Vector2:
    return world_to_map(to_local(world_pos))


func cell_to_global_pos(cell_pos: Vector2) -> Vector2:
    return to_global(map_to_world(cell_pos))


# Adjusts a global cell position (bottom corner) to be centred within the cell.
func center_global_pos_in_cell(world_pos: Vector2) -> Vector2:
    var half = cell_size / 2
    half.x = 0
    return world_pos + half


# https://github.com/gdquest-demos/godot-3-demos/blob/master/2017/final/09-Isometric%20grid-based%20movement/Player.gd
func cartesian_to_isometric(point: Vector2) -> Vector2:
    return Vector2(point.x - point.y, (point.x + point.y) / 2)


func set_world_cellv(v: Vector2, value):
    var cell_space = global_to_cell_pos(v)
    .set_cellv(cell_space, ground_to_tile[value])


func get_world_cellv(v: Vector2) -> int:
    var cell_space = global_to_cell_pos(v)
    var value = .get_cellv(cell_space)
    return tile_to_ground[value]


func attach_player_to_world(player):
    var old_grid = player.gridworld
    var dest = snap_global_to_cell(player.global_position)
    player.get_parent().remove_child(player)
    $"%YSort".add_child(player)
    player.gridworld = self
    if old_grid:
        dest = cell_to_global_pos(old_grid.global_to_cell_pos(dest))
    return center_global_pos_in_cell(dest)


func debug_draw_tiles(pen):
    var ground_to_color = {
        GroundType.EMPTY:  Color.white,
        GroundType.SOLID:  Color.red,
        GroundType.BORDER: Color.blue,
        GroundType.GOAL:   Color.purple,
    }
    var size = Vector2(5, 5)
    for x in range(-100, 100):
        for y in range(-100, 100):
            var cell = Vector2(x, y)
            var pos = cell_to_global_pos(cell)
            var ground = get_world_cellv(pos)
            var c = ground_to_color[ground]
            pen.draw_rect(Rect2(pos, size), c)
