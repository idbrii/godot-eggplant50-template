extends Node2D



var edges = [preload("res://games/Ooks2/edge.tscn")]
onready var random = RandomNumberGenerator.new()
var num_edges = 5
var standard_spacing = 80
var readied = false


# Called when the node enters the scene tree for the first time.
func _ready():
	#$GameMenu.
	random.randomize()
#	random.seed = hash("Godot") #Godot eggplant
	$cloud1.rect_position.x += random.randi_range(-100,100)
	$cloud2.rect_position.x += random.randi_range(-100,100)
	$cloud3.rect_position.x += random.randi_range(-100,100)
	$cloud4.rect_position.x += random.randi_range(-100,100)
	$ColorRock2.rect_position.x += random.randi_range(-100,100)
	$ColorRock3.rect_position.x += random.randi_range(-100,100)
	for ii in 4:
		for i in num_edges:
			var instance = edges[0].instance()
			instance.position.x = random.randi_range(-25,25) + i*standard_spacing + 170
			instance.position.y = random.randi_range(50,100) + ii*standard_spacing*0.7+50
			instance.rotation_degrees = random.randi_range(-45,45)
			var temp_scale = random.randf_range(0.5,1.5)
			instance.scale.x = temp_scale
			temp_scale = random.randf_range(0.5,3)
			if temp_scale > 2.5:
				temp_scale = random.randf_range(2,12)
			instance.scale.y = temp_scale
			
			add_child(instance)
	$SeedLabel.set_text("Seed: "+str(random.get_seed()))
	yield(get_tree().create_timer(0.5), "timeout")
	readied = true
	$Node2DMenu.z_index = VisualServer.CANVAS_ITEM_Z_MAX
	$TwoBody.z_index = VisualServer.CANVAS_ITEM_Z_MAX-2
	$Eggplantjam.z_index = VisualServer.CANVAS_ITEM_Z_MAX-3
	$Node2DYouWin.z_index = VisualServer.CANVAS_ITEM_Z_MAX-1
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
#	print(body)
	if readied:
		$Node2DYouWin/YouWinLabelMid.visible = true
		$Node2DYouWin.z_index = VisualServer.CANVAS_ITEM_Z_MAX
		yield(get_tree().create_timer(2.0), "timeout")
		$Node2DMenu/GameMenu.visible = true
		$Node2DMenu/GameMenu.call_deferred("popup")
#	print("Jam!")
#	print(body)
#	pass # Replace with function body.
