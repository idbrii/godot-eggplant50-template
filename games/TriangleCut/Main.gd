extends Node2D


# Declare member variables here. Examples:
var player_hp: int = 10 setget set_player_hp

var curr_atk = 0 setget set_curr_atk
var curr_def = 0 setget set_curr_def
var curr_moves = 1 setget set_curr_moves
var enemy_dmg_number_scene = preload("res://games/TriangleCut/EnemyDmg.tscn")
var player_dmg_number_scene = preload("res://games/TriangleCut/PlayerDmg.tscn")
var shield_dmg_scene = preload("res://games/TriangleCut/ShieldDmg.tscn")


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
    if $CanvasLayer/GameOver.visible:
        if Input.is_action_just_released("action1"):
            get_tree().reload_current_scene()


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
            for i in range(curr_def):
                var sds = shield_dmg_scene.instance()
                sds.position += Vector2(rand_range(30, 100), rand_range(-100, 100))
                add_child(sds)
        if $Enemy.attacking_for > curr_def:
            $CanvasLayer/HUD/VBoxContainer/HBoxHp/AnimationPlayer.play("main")
            var pds = player_dmg_number_scene.instance()
            pds.get_node("Label").text = "-"+str(max($Enemy.attacking_for - curr_def, 0))
            pds.global_position = Vector2()
            add_child(pds)
        else:
            pass # todo play some shield sound
        self.player_hp -= max($Enemy.attacking_for - curr_def, 0)
        if player_hp <= 0:
            game_over()
        $Enemy.next_turn()
        $Grid.update_active_option()
        
        self.curr_atk = 0
        self.curr_def = 0
        self.curr_moves = 1
        $Grid.player_turn = true
    else:
        yield(get_tree().create_timer(0.5), "timeout")
        $Grid.update_active_option()
    

func enemy_dmg_num():
    var dmg_num = enemy_dmg_number_scene.instance()
    dmg_num.get_node("Label").text = "-"+str(self.curr_atk)
    dmg_num.global_position = $Enemy.global_position
    add_child(dmg_num)

func game_over():
    $Grid.queue_free()
    $CanvasLayer/GameOver.visible = true
