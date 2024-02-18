extends Resource
class_name TriangleGameState

export(int) var health
export(Vector2) var loc
export(int) var level
export(int) var best

func _init(p_health = 10, p_loc = Vector2(), p_level = 1, p_best = 1) -> void:
    health = p_health
    loc = p_loc
    level = p_level
    best = p_best
