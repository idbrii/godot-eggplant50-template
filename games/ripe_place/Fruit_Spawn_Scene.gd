extends Node2D
export(PackedScene) var fruit_scene

var occupants = 0
var gravityArea

# Called when the node enters the scene tree for the first time.
func _ready():
	gravityArea = self.get_parent().find_node('gravityArea')
	drop_new_fruit()
#	$Timer.start()
	
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
func _on_SpawnArea_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	increment_occupants()

func _on_SpawnArea_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	decrement_occupants()

func increment_occupants():
	occupants += 1
#	print('spawn area entered: ', occupants)

func decrement_occupants():
	occupants -= 1
	#if occupants < 1 && !dropping_right_now:
	if occupants < 1: 
		drop_new_fruit()
#	print('spawn area exited: ', occupants)
#	var overlapping_areas = $SpawnArea.get_overlapping_areas()
#	print('overlapping_areas: ', overlapping_areas)
#	var overlapping_bodies = $SpawnArea.get_overlapping_bodies()
#	print('overlapping_bodies: ', overlapping_bodies)
