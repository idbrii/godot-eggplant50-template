extends Node2D


# Declare member variables here. Examples:

const max_player_hp: int = 10
var player_hp: int = max_player_hp setget set_player_hp

var curr_atk = 0 setget set_curr_atk
var curr_def = 0 setget set_curr_def
var curr_moves = 1 setget set_curr_moves
var enemy_dmg_number_scene = preload("res://games/TriangleCut/EnemyDmg.tscn")
var player_dmg_number_scene = preload("res://games/TriangleCut/PlayerDmg.tscn")
var shield_dmg_scene = preload("res://games/TriangleCut/ShieldDmg.tscn")
export(Resource) var game_state = preload("res://games/TriangleCut/state.tres")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    randomize()
    # check if not new game

    if game_state.level > 1:
        self.player_hp = game_state.health
        $Grid.set_player_loc(game_state.loc)
        $Enemy.set_level(game_state.level)
    else:
        if ResourceLoader.exists("user://triangle_cut.tres"):
            game_state.best = ResourceLoader.load("user://triangle_cut.tres").best
    $CanvasLayer/LvlHud/VBoxContainer/best.text = "Best: "+str(game_state.best)
    $CanvasLayer/LvlHud/VBoxContainer/level.text = "Level: "+str(game_state.level)
    $CanvasLayer/Fade/Tween.interpolate_property($CanvasLayer/Fade, "color", null, Color(0,0,0,0), 0.5)
    $CanvasLayer/Fade/Tween.start()

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
    $ParallaxBackground.scroll_offset += Vector2(1.0, 1.0)*2*delta
    if Input.is_action_just_pressed("action1"):
        $bg_music.play_fg(8)
    if $CanvasLayer/GameOver.visible:
        if Input.is_action_just_released("action1"):
            get_tree().reload_current_scene()


func _on_Grid_actions(atk, def, extra) -> void:
    # pause for a sec for action animation
    yield(get_tree().create_timer(0.75), "timeout")
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
        if $Enemy.hp <= 0:
            # overkill: heal player up to max
            var overkill_heal = min(-1*$Enemy.hp, max_player_hp-player_hp)
            self.player_hp += overkill_heal
            $CanvasLayer/HUD/VBoxContainer/HBoxHp/AnimationPlayer.play("main")
            if overkill_heal > 0:
                var pds = player_dmg_number_scene.instance()
                pds.get_node("Label").text = "+"+str(-1*$Enemy.hp)
                pds.global_position = Vector2()
                add_child(pds)
                yield(pds, "child_exiting_tree")
            next_enemy()
            return
        $Enemy.attack()
        yield(get_tree().create_timer(0.5), "timeout")
        if curr_def > 0:
            $CanvasLayer/HUD/VBoxContainer/HBoxDef/AnimationPlayer.play("main")
            for i in range(min(curr_def, $Enemy.attacking_for)):
                var sds = shield_dmg_scene.instance()
                sds.position += Vector2(rand_range(30, 100), rand_range(-100, 100))
                add_child(sds)
                yield(get_tree().create_timer(rand_range(0.1/curr_def, 0.6/curr_def)), "timeout")
        if $Enemy.attacking_for > curr_def:
            $CanvasLayer/HUD/VBoxContainer/HBoxHp/AnimationPlayer.play("main")
            var pds = player_dmg_number_scene.instance()
            pds.get_node("Label").text = "-"+str(max($Enemy.attacking_for - curr_def, 0))
            pds.global_position = Vector2()
            add_child(pds)

        self.player_hp -= max($Enemy.attacking_for - curr_def, 0)
        if player_hp <= 0:
            game_over()
        $Enemy.next_turn()
        # check if player stranded
        if $Grid.is_player_stuck():
            game_over()
            return
        $Grid.update_active_option()
        
        self.curr_atk = 0
        self.curr_def = 0
        self.curr_moves = 1
        $Grid.player_turn = true
    else:
        $Grid.player_turn = false
        yield(get_tree().create_timer(0.5), "timeout")
        $Grid.update_active_option()
        $Grid.player_turn = true
    

func enemy_dmg_num():
    var dmg_num = enemy_dmg_number_scene.instance()
    dmg_num.get_node("Label").text = "-"+str(self.curr_atk)
    dmg_num.global_position = $Enemy.global_position
    add_child(dmg_num)

func game_over():
    game_state.level = 1
    game_state.loc = Vector2()
    game_state.health = max_player_hp
    var result = ResourceSaver.save("user://triangle_cut.tres", game_state)
    $Grid.queue_free()
    $CanvasLayer/GameOver.visible = true

func next_enemy():
    $win_sfx.play()
    yield($win_sfx, "finished")
    $CanvasLayer/Fade/Tween.interpolate_property($CanvasLayer/Fade, "color", null, Color("#17111a"), 0.5)
    $CanvasLayer/Fade/Tween.start()
    game_state.health = player_hp
    game_state.loc = $Grid.player_loc
    if game_state.level > game_state.best:
        game_state.best = game_state.level
        
    game_state.level += 1
    yield($CanvasLayer/Fade/Tween, "tween_completed")
    get_tree().reload_current_scene()
    
