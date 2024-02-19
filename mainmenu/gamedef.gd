class_name GameDef
extends Resource

# Add a GameDef to your project folder and then add it to res://games/eggplant_games.tres


# Changing this class seems to require "Reload Current Project" before you'll
# see changes in Godot 3. I think that's improved in 4.

export(PackedScene) var initial_scene
export(String) var game_name
export(String) var game_author

# Label your inputs. If left blank, input_widget will use defaults.
export(String) var input_primary_action := "Primary"
export(String) var input_secondary_action := "Secondary"
export(String) var input_pause := "Pause"
export(String) var input_directions := "Movement"


func _init(p_initial_scene = null, p_game_name = "", p_game_author = "", p_input_primary_action = "", p_input_secondary_action = "", p_input_pause = "", p_input_directions = ""):
	initial_scene = p_initial_scene
	game_name = p_game_name
	game_author = p_game_author

	input_primary_action = p_input_primary_action
	input_secondary_action = p_input_secondary_action
	input_pause = p_input_pause
	input_directions = p_input_directions

