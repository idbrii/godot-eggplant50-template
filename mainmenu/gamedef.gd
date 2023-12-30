class_name GameDef
extends Resource

# Add a GameDef to your project folder and then add it to res://games/eggplant_games.tres


# Changing this class seems to require "Reload Current Project" before you'll
# see changes in Godot 3. I think that's improved in 4.

export(PackedScene) var initial_scene
export(String) var game_name
export(String) var game_author

func _init(p_initial_scene = null, p_game_name = "", p_game_author = ""):
    initial_scene = p_initial_scene
    game_name = p_game_name
    game_author = p_game_author
