extends Node2D
export(PackedScene) var BatScene

var bat

# Called when the node enters the scene tree for the first time.
func _ready():
	bat = BatScene.instance()
	new_game()

func new_game():
	bat.position = Vector2(32, 32)
	var grav_children = $gravityArea.get_children()
	for child in grav_children:
		if child.get('is_a_fruit'):
			$gravityArea.remove_child(child)
			
	self.add_child(bat)

func _on_HUD_start_game():
	new_game()
