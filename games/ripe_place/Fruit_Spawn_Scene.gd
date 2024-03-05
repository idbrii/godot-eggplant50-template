extends Node2D
export(PackedScene) var fruit_scene

var occupants = 0
var gravityArea

# Called when the node enters the scene tree for the first time.
func _ready():
	gravityArea = self.get_parent().find_node('gravityArea')
	var first_spawn_time = rand_range(1.0, 30.0)
	$spawn_timer.start(first_spawn_time)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	print('occupants', occupants)

func drop_new_fruit():
#	var bat = self.get_parent().find_node('bat')
	var fruit = fruit_scene.instance()
	fruit.position = self.position
#	bat.connect('overlaps', fruit, '_on_overlapped_by_bat')
	gravityArea.add_child(fruit)

#func _on_Timer_timeout():
#	var overlappers = $SpawnArea.get_overlapping_bodies()
#	print('overlappers: ', overlappers)

# The bat has an area, not a body, and does not
# move via physics.
# Also, if you make gravityArea monitorable, it will count as an area shape that never leaves.
func _on_SpawnArea_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	increment_occupants()

func _on_SpawnArea_area_shape_exited(_area_rid, _area, _area_shape_index, _local_shape_index):
	decrement_occupants()

func increment_occupants():
	occupants += 1
#	print('spawn area entered: ', occupants)

func decrement_occupants():
	occupants -= 1
	#if occupants < 1 && !dropping_right_now:
	if occupants < 1:
		$spawn_timer.start(rand_range(1, 3))
#		drop_new_fruit()
#	print('spawn area exited: ', occupants)
#	var overlapping_areas = $SpawnArea.get_overlapping_areas()
#	print('overlapping_areas: ', overlapping_areas)
#	var overlapping_bodies = $SpawnArea.get_overlapping_bodies()
#	print('overlapping_bodies: ', overlapping_bodies)

func _on_spawn_timer_timeout():
	print('timer done for ', self)
#	self.call_deferred('drop_new_fruit')
	self.drop_new_fruit()
