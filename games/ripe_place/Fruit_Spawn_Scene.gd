extends Node2D
export(PackedScene) var fruit_scene

var occupants = 0
var gravityArea
var have_spawned = false

# Called when the node enters the scene tree for the first time.
func _ready():
	gravityArea = self.get_parent().find_node('gravityArea')
	self.get_parent().find_node('hud').connect('start_game', self, 'reset')
	reset()

func reset():
	self.have_spawned = false
	var first_spawn_time = rand_range(1.0, 30.0)
	$spawn_timer.start(first_spawn_time)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	print('occupants', occupants)

func drop_new_fruit(initial_ripeness = 0):
	print('initial_ripeness: ', initial_ripeness)
	var fruit = fruit_scene.instance()
	fruit.position = self.position
	fruit.ripeness = initial_ripeness
	gravityArea.add_child(fruit)

# The bat has an area, not a body, and does not
# move via physics.
# Also, if you make gravityArea monitorable, it will count as an area shape that never leaves.
func _on_SpawnArea_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	increment_occupants()

func _on_SpawnArea_area_shape_exited(_area_rid, _area, _area_shape_index, _local_shape_index):
	decrement_occupants()

func increment_occupants():
	occupants += 1

func decrement_occupants():
	occupants -= 1
	if occupants < 1:
		$spawn_timer.start(rand_range(1, 3))

func _on_spawn_timer_timeout():
	self.drop_new_fruit(0 if self.have_spawned else randi() % 6)
	self.have_spawned = true
