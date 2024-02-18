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
    if atk > 0:
        $CanvasLayer/HUD/VBoxContainer/HBoxAtk/AnimationPlayer.play("main")
    if def > 0:
        $CanvasLayer/HUD/VBoxContainer/HBoxDef/AnimationPlayer.play("main")
    if extra > 0:
        $CanvasLayer/HUD/VBoxContainer/HBoxAp/AnimationPlayer.play("main")
    self.curr_moves -= 1
    self.curr_moves += extra
    self.curr_atk += atk
    self.curr_def += def
    if curr_moves < 1:
        $Grid.player_turn = false
        if curr_atk > 0:
            $Enemy/AtkSprite/AnimationPlayer.play("atk")
            yield($Enemy/AtkSprite/AnimationPlayer,"animation_finished")
        $Enemy.hp -= curr_atk
        $Enemy.attack()
        yield(get_tree().create_timer(1.5), "timeout")
        if curr_def > 0:
            $CanvasLayer/HUD/VBoxContainer/HBoxDef/AnimationPlayer.play("main")
        if $Enemy.attacking_for > curr_def:
            $CanvasLayer/HUD/VBoxContainer/HBoxHp/AnimationPlayer.play("main")
        else:
            pass # todo play some shield sound
        self.player_hp -= max($Enemy.attacking_for - curr_def, 0)
        $Enemy.next_turn()
        $Grid.update_active_option()
        
        self.curr_atk = 0
        self.curr_def = 0
        self.curr_moves = 1
        $Grid.player_turn = true
    else:
        yield(get_tree().create_timer(0.5), "timeout")
        $Grid.update_active_option()
    
