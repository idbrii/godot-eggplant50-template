extends Node2D


var move
var jamjar = preload("res://games/Ooks4/jamjar_RigidBody2D.tscn")
onready var spawnPosition = $spawnPoint.position
onready var spawner = $spawnPoint
var held_move_time = 0
var pixel = preload("res://games/Ooks4/ColorRect.tscn")
var colors =  ["#17111a","#7a213a","#e14141","#ffa070","#c44d29","#ffbf36","#753939","#cf7957","#ffd1ab","#39855a","#83e04c","#dcff70","#243b61","#3898ff","#6eeeff","#682b82","#bf3fb3","#ff80aa","#3e375c","#7884ab","#b2bcc2","#372538"]
var pixels = []
var random = RandomNumberGenerator.new()
var _noise = OpenSimplexNoise.new()
var spacing = 10
var column1x = 25
var column1y = 40
var column2x = 225
var column2y = column1y
var column3x = 425
var column3y = column1y
var current_correct = 3 #1, 2, or 3
var current_selector = 1
var level_count = 1
#simple; heavy weight down, light weight down, 
#simple edges, edges, persistence, 
#period, 
var notOdd_octaves = [4,4,3, 1,3,3, 3,3,3]
var notOdd_period = [6,6,6, 6,6,6, 3,6,6]
var notOdd_persistence = [0.8,0.8,0.8, 0.8,0.8,0.6, 0.6,0.6,0.5]
var notOdd_threshold1 = [0,0,0.2, 0,0,0, 0,-0.3,-0.3]
var notOdd_threshold2 = [1,1,1, 1,1,1, 1,0.4,0.4]
var notOdd_threshold3 = [3,3,3, 3,3,3, 3,0.1,0.1]
var notOdd_iiMod = [0,0.5,0.5, 0,0,0, 0,0,0.1]
var odd_octaves = [1,4,4, 1,3,3, 3,3,3]
var odd_period = [6,6,6, 6,6,6, 2,6,6]
var odd_persistence = [0.8,0.8,0.8, 0.8,0.8,0.4, 0.6,0.4,0.5]
var odd_threshold1 = [0,0,0, -0.2,-0.2,0, 0,-0.3,-0.3] # noise > odd_threshold1 and noise < odd_threshold2
var odd_threshold2 = [1,1,1, 0.2,0.2,1, 1,0.4,0.4]
var odd_threshold3 = [3,3,3, 3,3,3, 3,-0.1,0.1]
var odd_iiMod = [0,0,0, 0,0,0, 0,0,0.1]

var all_mod = [1,1,1, 1,1,1, 1]
var odd_mod = [1,1,1, 1,1,1, 1]
var regened = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var instance
	
	$background.z_index = VisualServer.CANVAS_ITEM_Z_MIN
	random.randomize()
	generate_tables1()

func delete_tables():
	var temp = pixels.size()
	#print(temp)
	var tempCountColumns = 0
	for i in temp:
			tempCountColumns += 1
			if tempCountColumns == 25:
				tempCountColumns = 0
				#yield(get_tree().create_timer(0.01), "timeout")
				#print(pixels.size()-1)
				remove_child(pixels[pixels.size()-1])
				#print(pixels.size()-1)
				pixels.remove(pixels.size()-1)
			else:
				remove_child(pixels[pixels.size()-1])
				pixels.remove(pixels.size()-1)
	#print(pixels.size()-1)


func generate_tables1():
	if level_count < 1:
		level_count = 1
	$count.text = str(level_count)
	$bonus.visible = false
	if level_count >= 9:
		$bonus.visible = true
		if regened == false: 
			all_mod = [1,1,1, 1,1,1, 1]
			odd_mod = [1,1,1, 1,1,1, 1]
			_noise.seed = randi()
			if randf() > 0.6:
				all_mod[0] = random.randf_range(0.25,2)
			if randf() > 0.6:
				all_mod[1] = random.randf_range(0.25,2)
			if randf() > 0.6:
				all_mod[2] = random.randf_range(-1.5,1.5)
			if randf() > 0.6:
				all_mod[3] = random.randf_range(1,3)
			if randf() > 0.6:
				all_mod[4] = random.randf_range(0.05,1.5)
			if randf() > 0.6:
				all_mod[5] = random.randf_range(0.5,2)+all_mod[4]
			if randf() > 0.6:
				all_mod[6] = random.randf_range(-1.5,1.5)
			if randf() > 0.7:
				odd_mod[0] = random.randf_range(0.25,2)
#				print("oddmod")
			if randf() > 0.7:
				odd_mod[1] = random.randf_range(0.25,2)
#				print("oddmod")
			if randf() > 0.7:
				odd_mod[2] = random.randf_range(-1.5,1.5)
#				print("oddmod")
			if randf() > 0.7:
				odd_mod[3] = random.randf_range(0,3)
#				print("oddmod")
			if randf() > 0.7:
				odd_mod[4] = random.randf_range(0.05,1.5)
#				print("oddmod")
			if randf() > 0.7:
				odd_mod[5] = random.randf_range(0.5,2)+odd_mod[4]
#				print("oddmod")
			if randf() > 0.7:
				odd_mod[6] = random.randf_range(-1.5,1.5)
#				print("oddmod")
			odd_mod[random.randi_range(0,6)] = 1.5
#			print(all_mod)
#			print(odd_mod)
#			print("next")
	else:
		all_mod = [1,1,1, 1,1,1, 1]
		odd_mod = [1,1,1, 1,1,1, 1]
	current_correct = random.randi_range(1,3)
	#print(current_correct)
	var current_level = level_count-1
	if current_level > notOdd_octaves.size()-1:
		current_level = notOdd_octaves.size()-1
	
	_noise.seed = randi()
	var noise_result = 0
	if current_correct != 1:
		_noise.octaves = int(notOdd_octaves[current_level]*all_mod[0])
		_noise.period = int(notOdd_period[current_level]*all_mod[1])
		_noise.persistence = notOdd_persistence[current_level]*all_mod[2]
		for i in 18:
			yield(get_tree().create_timer(0.01), "timeout")
			for ii in 25:
				noise_result = _noise.get_noise_2d(i,ii)+notOdd_iiMod[current_level]*ii/25*all_mod[3]
				pixels.append(pixel.instance()) #instance = person[0].instance()
				if noise_result > notOdd_threshold1[current_level]*all_mod[4] and noise_result < notOdd_threshold2[current_level]*all_mod[5]:
					pixels[pixels.size()-1].color = colors[(level_count-1)%(colors.size())]
					if noise_result > notOdd_threshold3[current_level]*all_mod[6]:
						pixels[pixels.size()-1].color = colors[(level_count)%(colors.size())]
				else:
					pass
				pixels[pixels.size()-1].rect_position = Vector2(i*spacing+column1x,ii*spacing+column1y)
				add_child(pixels[pixels.size()-1])
	else:
		_noise.octaves = int(odd_octaves[current_level]*all_mod[0]*odd_mod[0])
		_noise.period = int(odd_period[current_level]*all_mod[1]*odd_mod[1])
		_noise.persistence = odd_persistence[current_level]*all_mod[2]*odd_mod[2]
		for i in 18:
			yield(get_tree().create_timer(0.01), "timeout")
			for ii in 25:
				noise_result = _noise.get_noise_2d(i,ii)+odd_iiMod[current_level]*ii/25*all_mod[3]*odd_mod[3]
				pixels.append(pixel.instance()) #instance = person[0].instance()
				if noise_result > odd_threshold1[current_level]*all_mod[4]*odd_mod[4] and noise_result < odd_threshold2[current_level]*all_mod[5]*odd_mod[5]:
					pixels[pixels.size()-1].color = colors[(level_count-1)%(colors.size())]
					if noise_result > odd_threshold3[current_level]*all_mod[6]*odd_mod[6]:
						pixels[pixels.size()-1].color = colors[(level_count)%(colors.size())]
				else:
					pass
				pixels[pixels.size()-1].rect_position = Vector2(i*spacing+column1x,ii*spacing+column1y)
				add_child(pixels[pixels.size()-1])
	
	_noise.seed = randi()
	if current_correct != 2:
		_noise.octaves = int(notOdd_octaves[current_level]*all_mod[0])
		_noise.period = int(notOdd_period[current_level]*all_mod[1])
		_noise.persistence = notOdd_persistence[current_level]*all_mod[2]
		for i in 18:
			yield(get_tree().create_timer(0.01), "timeout")
			for ii in 25:
				noise_result = _noise.get_noise_2d(i,ii)+notOdd_iiMod[current_level]*ii/25*all_mod[3]
				pixels.append(pixel.instance()) #instance = person[0].instance()
				if noise_result > notOdd_threshold1[current_level]*all_mod[4] and noise_result < notOdd_threshold2[current_level]*all_mod[5]:
					pixels[pixels.size()-1].color = colors[(level_count-1)%(colors.size())]
					if noise_result > notOdd_threshold3[current_level]*all_mod[6]:
						pixels[pixels.size()-1].color = colors[(level_count)%(colors.size())]
				else:
					pass
				pixels[pixels.size()-1].rect_position = Vector2(i*spacing+column2x,ii*spacing+column2y)
				add_child(pixels[pixels.size()-1])
	else:
		_noise.octaves = int(odd_octaves[current_level]*all_mod[0]*odd_mod[0])
		_noise.period = int(odd_period[current_level]*all_mod[1]*odd_mod[1])
		_noise.persistence = odd_persistence[current_level]*all_mod[2]*odd_mod[2]
		for i in 18:
			yield(get_tree().create_timer(0.01), "timeout")
			for ii in 25:
				noise_result = _noise.get_noise_2d(i,ii)+odd_iiMod[current_level]*ii/25*all_mod[3]*odd_mod[3]
				pixels.append(pixel.instance()) #instance = person[0].instance()
				if noise_result > odd_threshold1[current_level]*all_mod[4]*odd_mod[4] and noise_result < odd_threshold2[current_level]*all_mod[5]*odd_mod[5]:
					pixels[pixels.size()-1].color = colors[(level_count-1)%(colors.size())]
					if noise_result > odd_threshold3[current_level]*all_mod[6]*odd_mod[6]:
						pixels[pixels.size()-1].color = colors[(level_count)%(colors.size())]
				else:
					pass
				pixels[pixels.size()-1].rect_position = Vector2(i*spacing+column2x,ii*spacing+column2y)
				add_child(pixels[pixels.size()-1])
	
	_noise.seed = randi()
	if current_correct != 3:
		_noise.octaves = int(notOdd_octaves[current_level]*all_mod[0])
		_noise.period = int(notOdd_period[current_level]*all_mod[1])
		_noise.persistence = notOdd_persistence[current_level]*all_mod[2]
		for i in 18:
			yield(get_tree().create_timer(0.01), "timeout")
			for ii in 25:
				noise_result = _noise.get_noise_2d(i,ii)+notOdd_iiMod[current_level]*ii/25*all_mod[3]
				pixels.append(pixel.instance()) #instance = person[0].instance()
				if noise_result > notOdd_threshold1[current_level]*all_mod[4] and noise_result < notOdd_threshold2[current_level]*all_mod[5]:
					pixels[pixels.size()-1].color = colors[(level_count-1)%(colors.size())]
					if noise_result > notOdd_threshold3[current_level]*all_mod[6]:
						pixels[pixels.size()-1].color = colors[(level_count)%(colors.size())]
				else:
					pass
				pixels[pixels.size()-1].rect_position = Vector2(i*spacing+column3x,ii*spacing+column3y)
				add_child(pixels[pixels.size()-1])
	else:
		_noise.octaves = int(odd_octaves[current_level]*all_mod[0]*odd_mod[0])
		_noise.period = int(odd_period[current_level]*all_mod[1]*odd_mod[1])
		_noise.persistence = odd_persistence[current_level]*all_mod[2]*odd_mod[2]
		for i in 18:
			yield(get_tree().create_timer(0.01), "timeout")
			for ii in 25:
				noise_result = _noise.get_noise_2d(i,ii)+odd_iiMod[current_level]*ii/25*all_mod[3]*odd_mod[3]
				pixels.append(pixel.instance()) #instance = person[0].instance()
				if noise_result > odd_threshold1[current_level]*all_mod[4]*odd_mod[4] and noise_result < odd_threshold2[current_level]*all_mod[5]*odd_mod[5]:
					pixels[pixels.size()-1].color = colors[(level_count-1)%(colors.size())]
					if noise_result > odd_threshold3[current_level]*all_mod[6]*odd_mod[6]:
						pixels[pixels.size()-1].color = colors[(level_count)%(colors.size())]
				else:
					pass
				pixels[pixels.size()-1].rect_position = Vector2(i*spacing+column3x,ii*spacing+column3y)
				add_child(pixels[pixels.size()-1])
	


func _process(delta):
	if Input.is_action_just_pressed("move_down"):
		current_selector = 4
		$Selector.visible = false
		$labelRegen/highlighted.visible = true
	if Input.is_action_just_pressed("move_up"):
		if current_selector == 4:
			current_selector = 2
			$Selector.visible = true
			$labelRegen/highlighted.visible = false
			$Selector.position = $label2.rect_position
	if Input.is_action_just_pressed("move_left"):
		if current_selector == 1:
			current_selector = 3
			$Selector.position = $label3.rect_position
		elif current_selector == 2:
			current_selector = 1
			$Selector.position = $label1.rect_position
		elif current_selector == 3:
			current_selector = 2
			$Selector.position = $label2.rect_position
	if Input.is_action_just_pressed("move_right"):
		if current_selector == 1:
			current_selector = 2
			$Selector.position = $label2.rect_position
		elif current_selector == 2:
			current_selector = 3
			$Selector.position = $label3.rect_position
		elif current_selector == 3:
			current_selector = 1
			$Selector.position = $label1.rect_position
	if Input.is_action_just_pressed("action1"):
		if current_selector == 4: #regen
			regened = true
			delete_tables()
			yield(get_tree().create_timer(0.1), "timeout")
			generate_tables1()
		else:
			regened = false
			if current_selector == current_correct:
				$titleLabel.visible = false
				$successNode/successLabel.visible = true
				$successNode.z_index = VisualServer.CANVAS_ITEM_Z_MAX
				yield(get_tree().create_timer(0.6), "timeout")
				delete_tables()
				level_count += 1
				yield(get_tree().create_timer(0.1), "timeout")
				generate_tables1()
				yield(get_tree().create_timer(0.3), "timeout")
				$titleLabel.visible = true
				$successNode/successLabel.visible = false
			else:
				$titleLabel.visible = false
				$successNode/failLabel.visible = true
				$successNode.z_index = VisualServer.CANVAS_ITEM_Z_MAX
				yield(get_tree().create_timer(0.6), "timeout")
				delete_tables()
				level_count -= 1
				yield(get_tree().create_timer(0.1), "timeout")
				generate_tables1()
				yield(get_tree().create_timer(0.3), "timeout")
				$titleLabel.visible = true
				$successNode/failLabel.visible = false
	
	
	
	
	
	
	
	
	
#	move = Input.get_vector("move_left", "move_right", "move_up", "move_down")
#	if move.x != 0 or move.y != 0:
#		held_move_time += delta
#		if held_move_time > 2:
#			held_move_time = 2
#	else:
#		held_move_time = 0
#	if spawner != null:# and not setting_up_new_board:
#		spawner.position += move*held_move_time
#
#		if Input.is_action_pressed("action1"):
#			var instance = jamjar.instance()
#			instance.position = spawner.position
#			#instance.position.x += int(rand_range(-100,100))
#			add_child(instance)
		
#		if Input.is_action_just_pressed("action2"):
#			current_district.rotation_degrees += 90
		
#		if Input.is_action_just_pressed("action1"):
#			#print(current_district.district_greens)
#			#print(current_district.district_purples)
#			var is_valid_district = true
#			current_district.active = false
#			for i in current_district.bodies:
#				if counted_bodies.has(i):
#					#print("error recounted person")
#					is_valid_district = false
#			if is_valid_district:
#				for i in current_district.bodies:
#					counted_bodies.append(i)
#					#print(counted_bodies)
#				current_district._parent_sending_deactivate()
#				make_new_district()
