extends Node2D


# Declare member variables here. Examples:
const SIDE_LEN = 60
var center: Vector2 = Vector2.ZERO
var radius = 3

var action_scene = preload("res://games/TriangleCut/Action.tscn")

var adjacencies = {}
var triangles = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if not center in adjacencies:
        adjacencies[center] = []
    var curr_nodes = [center]
    var new_nodes = []
    for i in range(radius):
        for curr in curr_nodes:
            if not curr in adjacencies:
                adjacencies[curr] = []
            for n in create_edges_for(curr):
                if not n in adjacencies:
                    adjacencies[n] = []
                if not n in adjacencies[curr] and not curr in adjacencies[n]:
                    adjacencies[curr].append(n)
                    adjacencies[n].append(curr)
                    new_nodes.append(n)
                    var line = Line2D.new()
                    line.add_point(curr)
                    line.add_point(n)
                    $Edges.add_child(line)
        curr_nodes = new_nodes
        new_nodes = []
    # delete extra
    var to_delete = []
    for n in adjacencies:
        if adjacencies[n].size() < 2:
            to_delete.append(n)
    for line in $Edges.get_children():
        if line.points[0] in to_delete or line.points[1] in to_delete:
            line.queue_free()
    for n in to_delete:
        for m in adjacencies[n]:
            adjacencies[m].remove(adjacencies[m].find(n))
        adjacencies.erase(n)
    create_triangles()
            
    
    
func create_edges_for(pos: Vector2) -> Array:
    var ret = []
    ret.push_back(pos + Vector2(-SIDE_LEN, 0)) # left
    ret.push_back(pos + Vector2(SIDE_LEN, 0))  # right
    ret.push_back(pos + Vector2(-1, -sqrt(3)).normalized()*SIDE_LEN) # top left
    ret.push_back(pos + Vector2(-1, sqrt(3)).normalized()*SIDE_LEN) # bottom left
    ret.push_back(pos + Vector2(1, -sqrt(3)).normalized()*SIDE_LEN) # top right
    ret.push_back(pos + Vector2(1, sqrt(3)).normalized()*SIDE_LEN) # bottom left
    return ret

func create_triangles():
    for n1 in adjacencies:
        for n2 in adjacencies[n1]:
            for o in adjacencies[n2]:
                # check if they have common neighbor
                if o in adjacencies[n1]:
                    var tri_key = [n1, n2, o]
                    tri_key.sort()
                    if not tri_key in triangles:
                        var action = action_scene.instance()
                        action.global_position = (n1+n2+o)/3.0
                        triangles[tri_key] = action
                        $Actions.add_child(action)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
