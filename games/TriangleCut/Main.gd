extends Node2D


# Declare member variables here. Examples:
var player_hp: int = 10 setget set_player_hp

var curr_atk = 0 setget set_curr_atk
var curr_def = 0 setget set_curr_def
var curr_moves = 1 setget set_curr_moves


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    randomize()

func set_curr_moves(new_val):
    curr_moves = new_val
    $PlayerAP.text = "Your AP: "+str(curr_moves)

func set_curr_def(new_val):
    curr_def = new_val
    $PlayerDef.text = "Current Def: "+str(curr_def)

func set_curr_atk(new_val):
    curr_atk = new_val
    $PlayerAtk.text = "Current Atk: "+str(curr_atk)
    
func set_player_hp(new_val):
    player_hp = new_val
    $PlayerHP.text = "Your HP: "+str(player_hp)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_Grid_actions(atk, def, extra) -> void:
    self.curr_moves -= 1
    self.curr_moves += extra
    self.curr_atk += atk
    self.curr_def += def
    if curr_moves < 1:
        $Grid.player_turn = false
        self.player_hp -= $Enemy.attacking_for - curr_def
        $Enemy.hp -= curr_atk
        $Enemy.next_turn()
        
        self.curr_atk = 0
        self.curr_def = 0
        self.curr_moves = 1
        $Grid.player_turn = true
    else:
        pass
    
