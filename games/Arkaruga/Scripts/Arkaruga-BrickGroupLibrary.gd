extends Resource

export(Array, PackedScene) var easyGroups
export(Array, PackedScene) var medGroups
export(Array, PackedScene) var hardGroups

func _init():
	pass
	
func getRandomEasyGroup():
	return easyGroups[ randi() % easyGroups.size() ]
	
func getRandomMedGroup():
	return medGroups[ randi() % medGroups.size() ]
	
func getRandomHardGroup():
	return hardGroups[ randi() % hardGroups.size() ]
