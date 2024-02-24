extends TileMap

# https://www.reddit.com/r/godot/comments/fuejci/having_trouble_with_snapping_to_isometric_grid/fmcl07f/
func get_cell_global_position(world_pos: Vector2) -> Vector2:
    return to_global(map_to_world(world_to_map(to_local(world_pos))))

# https://github.com/gdquest-demos/godot-3-demos/blob/master/2017/final/09-Isometric%20grid-based%20movement/Player.gd
func cartesian_to_isometric(point: Vector2) -> Vector2:
    return Vector2(point.x - point.y, (point.x + point.y) / 2)
