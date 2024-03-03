extends TileMap

const Container = preload("res://games/drop_walker/code/util/container.gd")

# Funky offset because my tiles render one position below where they look like they should be.
const TILE_OFFSET := Vector2.ONE * 2


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
            set_world_cellv(g.global_position, GroundType.GOAL)


# Returns a global position.
# https://www.reddit.com/r/godot/comments/fuejci/having_trouble_with_snapping_to_isometric_grid/fmcl07f/
func snap_global_to_cell(world_pos: Vector2) -> Vector2:
    return to_global(map_to_world(world_to_map(to_local(world_pos))))


func global_to_cell_pos(world_pos: Vector2) -> Vector2:
    return world_to_map(to_local(world_pos)) - TILE_OFFSET


func cell_to_global_pos(cell_pos: Vector2) -> Vector2:
    return to_global(map_to_world(cell_pos + TILE_OFFSET))


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
    return dest

