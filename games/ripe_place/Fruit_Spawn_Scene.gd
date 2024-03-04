extends Node2D
export(PackedScene) var fruit_scene

var occupants = 0
var gravityArea

# Called when the node enters the scene tree for the first time.
func _ready():
	gravityArea = self.get_parent().find_node('gravityArea')
	drop_new_fruit()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	print('occupants', occupants)

func drop_new_fruit():
	var fruit = fruit_scene.instance()
	fruit.position = self.position
	gravityArea.add_child(fruit)

func _on_SpawnArea_body_entered(body):
	occupants += 1

func _on_SpawnArea_body_exited(body):
	occupants -= 1
	#if occupants < 1 && !dropping_right_now:
	if occupants < 1: 
		drop_new_fruit()
