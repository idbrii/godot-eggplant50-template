extends Node2D
export(PackedScene) var fruit_scene

var occupants = 0
var gravityArea
#var dropping_right_now = false
#var fruit

# Called when the node enters the scene tree for the first time.
func _ready():
	gravityArea = self.get_parent().find_node('gravityArea')
	drop_new_fruit()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	print('occupants', occupants)

func drop_new_fruit():
#	dropping_right_now = true
#	print('Dropping fruit')
	var fruit = fruit_scene.instance()
	fruit.position = self.position
#	fruit.connect('tree_entered', self, 'on_fruit_entered_tree')
	gravityArea.add_child(fruit)

#func on_fruit_entered_tree():
#	dropping_right_now = false
#	fruit.disconnect('tree_entered', self, 'on_fruit_entered_tree')
#	fruit = null
#	print('Drop done.')

func _on_SpawnArea_body_entered(body):
	occupants += 1

func _on_SpawnArea_body_exited(body):
	occupants -= 1
	#if occupants < 1 && !dropping_right_now:
	if occupants < 1: 
		drop_new_fruit()
