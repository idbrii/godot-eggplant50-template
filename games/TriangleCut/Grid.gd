extends Node2D
signal actions(atk, def, extra)


# Declare member variables here. Examples:
const SIDE_LEN = 60
var center: Vector2 = Vector2.ZERO
var radius = 3

var action_scene = preload("res://games/TriangleCut/Action.tscn")

var adjacencies = {}
var triangles = {}

var active_option setget set_active_option  # player's choice to cut
var player_turn: bool = true
var player_loc: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    randomize()
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
                    line.default_color = Color("#7884ab")
                    line.width = 2
                    line.joint_mode = Line2D.LINE_JOINT_ROUND
                    line.add_point(curr)
                    line.add_point(n)
                    $Edges.add_child(line)
        curr_nodes = new_nodes
        new_nodes = []
    # delete extra
    var to_delete = []
    for n in adjacencies:
        adjacencies[n].sort()
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
    $Player.global_position = center
    player_loc = center
    self.active_option = adjacencies[center][0]
    adjacencies[$Player.position].sort_custom(self, "sort_points_cw")
#    find_line($Player.position, active_option).width = 8
    
func sort_points_cw(p1, p2):
    # hackey, depends on player pos, only works on current player node
    var center = $Player.position
    var p1p = p1 - center
    var p2p = p2 - center
    
    return p1p.angle() < p2p.angle()

    
    
func create_edges_for(pos: Vector2) -> Array:
    var ret = []
    # CW order
    ret.push_back(pos + Vector2(-SIDE_LEN, 0)) # left
    ret.push_back(pos + Vector2(-1, -sqrt(3)).normalized()*SIDE_LEN) # top left
    ret.push_back(pos + Vector2(1, -sqrt(3)).normalized()*SIDE_LEN) # top right
    ret.push_back(pos + Vector2(SIDE_LEN, 0))  # right
    ret.push_back(pos + Vector2(1, sqrt(3)).normalized()*SIDE_LEN) # bottom right
    ret.push_back(pos + Vector2(-1, sqrt(3)).normalized()*SIDE_LEN) # bottom left
    
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

func set_active_option(new_val):
    var curr = find_line($Player.position, active_option)
    if curr != null:
        curr.width = 2
        curr.default_color = Color("#7884ab")
    active_option = new_val
    var new = find_line($Player.position, active_option)
#    new.width = 4
    new.default_color = Color("#bf3fb3")
    

func find_line(p1, p2):
    for line in $Edges.get_children():
        if (line.points[0] == p1 and line.points[1] == p2) or (line.points[1] == p1 and line.points[0] == p2):
            return line

func traverse_active_edge():
    # Delete the line
    var line = find_line($Player.position, active_option)
    adjacencies[$Player.position].remove(adjacencies[$Player.position].find(active_option))
    adjacencies[active_option].remove(adjacencies[active_option].find($Player.position))
    
    # Activate triangle and delete
    var actions = {"atk": 0 , "def": 0, "extra": 0}
    var tris_to_del = []
    for tri in triangles:
        if active_option in tri and $Player.position in tri:
            actions[triangles[tri].type] += 1
            triangles[tri].activate()
            tris_to_del.append(tri)
        
    for tri in tris_to_del:
        triangles.erase(tri)
    
    # Particles
    $LineParticles.position = (player_loc + active_option)/2
    $LineParticles.emitting = true
    # Move player to new loc
    player_loc = active_option
    $Tween.interpolate_property($Player, "position", null, active_option, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
    $Tween.start()
    $Player/AnimationPlayer.play("Move")
    
    yield($Tween, "tween_completed")
    adjacencies[$Player.position].sort_custom(self, "sort_points_cw")
    
    line.queue_free()
    
    # TODO: deal with when player strands themselves
    
    emit_signal("actions", actions["atk"], actions["def"], actions["extra"])
    
func update_active_option():
    self.set_active_option(adjacencies[$Player.position][0])

func process_active(delta):
    var line = find_line($Player.position, active_option)
    if line != null:
        line.width = (sin(OS.get_ticks_msec()/200.0)+2.0)*4/3.0

func _process(delta: float) -> void:
    if not player_turn:
        return
    process_active(delta)
    var curr_idx = adjacencies[player_loc].find(active_option)
    var num_adj = len(adjacencies[player_loc])
    if Input.is_action_just_pressed("move_right"):
        self.active_option = adjacencies[player_loc][(curr_idx+1) % num_adj]
    if Input.is_action_just_pressed("move_left"):
        self.active_option = adjacencies[player_loc][(curr_idx-1) % num_adj]
    if Input.is_action_just_pressed("action1"):
        traverse_active_edge()


func _on_Grid_actions(atk, def, extra) -> void:
    print("atk: "+str(atk))
    print("def: "+str(def))
    print("extra: "+str(extra))

func set_player_loc(new_loc):
    $Player.position = new_loc
    player_loc = new_loc
    update_active_option()
