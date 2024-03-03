extends Node2D

export(PackedScene) var fruit_scene
export(Vector2) var gravity_center
export(float) var grav_units_sq_per_sec
var fruit

func _process(_delta):
	var to_gcenter = gravity_center - fruit.position
	var to_gcenter_mag = to_gcenter.normalized() * grav_units_sq_per_sec
	print('mag', to_gcenter_mag)


# Called when the node enters the scene tree for the first time.
func _ready():
	fruit = fruit_scene.instance()
	fruit.position = Vector2(64, 64)
	$gravityArea.add_child(fruit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
