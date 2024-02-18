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
    $CanvasLayer/HUD/VBoxContainer/HBoxAp/PlayerAP.text = ": "+str(curr_moves)

func set_curr_def(new_val):
    curr_def = new_val
    $CanvasLayer/HUD/VBoxContainer/HBoxDef/PlayerDef.text = ": "+str(curr_def)

func set_curr_atk(new_val):
    curr_atk = new_val
    $CanvasLayer/HUD/VBoxContainer/HBoxAtk/PlayerAtk.text = ": "+str(curr_atk)
    
func set_player_hp(new_val):
    player_hp = new_val
    $CanvasLayer/HUD/VBoxContainer/HBoxHp/PlayerHP.text = ": "+str(player_hp)


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
        $Enemy.hp -= curr_atk
        yield(get_tree().create_timer(1.0), "timeout")
        self.player_hp -= $Enemy.attacking_for - curr_def
        $Enemy.next_turn()
        $Grid.update_active_option()
        
        self.curr_atk = 0
        self.curr_def = 0
        self.curr_moves = 1
        $Grid.player_turn = true
    else:
        yield(get_tree().create_timer(0.5), "timeout")
        $Grid.update_active_option()
    
