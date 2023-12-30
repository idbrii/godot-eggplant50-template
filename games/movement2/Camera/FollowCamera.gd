extends Camera2D


var Target


# Called when the node enters the scene tree for the first time.
func _ready():
	Target = get_tree().get_nodes_in_group("Player")
	if Target != null: 
		Target = Target[0] #because get_nodes_in_group returns an array even if it's an array of size 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Target != null:
		position = Target.position
	else:
		print("FollowCamera doesn't have a target")
