extends Node2D


var person = [preload("res://games/Ooks3/person.tscn"),preload("res://games/Ooks3/personGreen.tscn")]
var districts = [preload("res://games/Ooks3/districts/n.tscn"),preload("res://games/Ooks3/districts/plus.tscn"),preload("res://games/Ooks3/districts/dumbbell.tscn")]
var voters = []
var district_children = []
var random = RandomNumberGenerator.new()
var _noise = OpenSimplexNoise.new()
var purples = 0
var greens = 0
var move
var bodies = []
var counted_bodies = []
var district_purples = []
var district_greens = []
var spacing = 20
var held_move_time = 0.0
var current_district
var current_district_num = 0
var total_districts = 6
var setting_up_new_board = false
var num_round = 1
var gameover = false


func _ready():
	$background.z_index = VisualServer.CANVAS_ITEM_Z_MIN
	random.randomize()
	_noise.seed = 0#randi()
	_noise.octaves = 4
	_noise.period = 5.0
	_noise.persistence = 0.8
	purples = 0
	greens = 0
	yield(get_tree().create_timer(0.5), "timeout")
	$titles.visible = true
	yield(get_tree().create_timer(0.5), "timeout")
	var instance
	for i in 20:
		yield(get_tree().create_timer(0.035), "timeout")
		for ii in 10:
			if _noise.get_noise_2d(i,ii) > 0:
				voters.append(person[0].instance()) #instance = person[0].instance()
				purples += 1
			else:
				voters.append(person[1].instance()) #instance = person[1].instance()
				greens += 1
			voters[voters.size()-1].position = Vector2(i*spacing+100,ii*spacing+100)
			add_child(voters[voters.size()-1])
	yield(get_tree().create_timer(0.5), "timeout")
	$counts.visible = true
	yield(get_tree().create_timer(0.5), "timeout")
	make_new_district()
#	print("purples: " + str(purples))
#	print("greens: " + str(greens))


func _process(delta):
	move = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if move.x != 0 or move.y != 0:
		held_move_time += delta
		if held_move_time > 1:
			held_move_time = 1
	else:
		held_move_time = 0
	if current_district != null and not setting_up_new_board:
		current_district.position += move*held_move_time
		
		if Input.is_action_just_pressed("action2"):
			current_district.rotation_degrees += 90
		
		if Input.is_action_just_pressed("action1"):
			#print(current_district.district_greens)
			#print(current_district.district_purples)
			var is_valid_district = true
			current_district.active = false
			for i in current_district.bodies:
				if counted_bodies.has(i):
					#print("error recounted person")
					is_valid_district = false
			if is_valid_district and current_district.bodies.size() > 0:
				for i in current_district.bodies:
					counted_bodies.append(i)
					#print(counted_bodies)
				current_district._parent_sending_deactivate()
				make_new_district()
			else:
				#print("game over")
				$failLabel.visible = true
				gameover = true
				yield(get_tree().create_timer(5.0), "timeout")
				$UI/PauseMenu.visible = true
				$UI/PauseMenu.call_deferred("popup")


func count_totals():
	var total_purple = 0
	var total_green = 0
	for i in district_purples.size():
		total_purple += district_purples[i]
		total_green += district_greens[i]
	$counts/purplecount.text = str(total_purple)
	$counts/greencount.text = str(total_green)
	if current_district_num >= total_districts:
		if total_purple > total_green:
			new_board()
		else:
			#print("game over")
			$failLabel.visible = true
			gameover = true
			yield(get_tree().create_timer(5.0), "timeout")
			$UI/PauseMenu.visible = true
			$UI/PauseMenu.call_deferred("popup")


func new_board():
	if current_district_num >= total_districts:
		$successLabel.visible = true
		setting_up_new_board = true
		current_district = null
		current_district_num = 0
		for i in voters:
			yield(get_tree().create_timer(0.005), "timeout")
			i.queue_free()
		for i in district_children:
			i.queue_free()
		if num_round == 3:
			#print("win game over")
			#yield(get_tree().create_timer(2.0), "timeout")
			$UI/PauseMenu.visible = true
			$UI/PauseMenu.call_deferred("popup")
			gameover = true
		else:
			district_children = []
			voters = []
			counted_bodies = []
			district_greens = []
			district_purples = []
			get_node("counts/districtcount1").bbcode_text = "1: "
			get_node("counts/districtcount2").bbcode_text = "2: "
			get_node("counts/districtcount3").bbcode_text = "3: "
			get_node("counts/districtcount4").bbcode_text = "4: "
			get_node("counts/districtcount5").bbcode_text = "5: "
			get_node("counts/districtcount6").bbcode_text = "6: "
			$counts/purplecount.text = "0"
			$counts/greencount.text = "0"
			
			if num_round == 1:
				num_round += 1
				for i in 18:
					yield(get_tree().create_timer(0.035), "timeout")
					for ii in 8:
						if _noise.get_noise_2d(i,ii) > 0.15:
							voters.append(person[0].instance()) #instance = person[0].instance()
							purples += 1
						else:
							voters.append(person[1].instance()) #instance = person[1].instance()
							greens += 1
						voters[voters.size()-1].position = Vector2(i*spacing+100+spacing,ii*spacing+100+spacing)
						add_child(voters[voters.size()-1])
			elif num_round == 2:
				num_round += 1
				for i in 16:
					yield(get_tree().create_timer(0.035), "timeout")
					for ii in 6:
						if _noise.get_noise_2d(i,ii) < 0.05 and _noise.get_noise_2d(i,ii) > -0.05:
							voters.append(person[0].instance()) #instance = person[0].instance()
							purples += 1
						else:
							voters.append(person[1].instance()) #instance = person[1].instance()
							greens += 1
						voters[voters.size()-1].position = Vector2(i*spacing+100+spacing+spacing,ii*spacing+100+spacing+spacing)
						add_child(voters[voters.size()-1])
			yield(get_tree().create_timer(1.0), "timeout")
			$successLabel.visible = false
			yield(get_tree().create_timer(0.5), "timeout")
			setting_up_new_board = false
			make_new_district()


func _district_sending_timeout():
	var is_valid_district = true
	for i in current_district.bodies:
		if counted_bodies.has(i):
			#print("error recounted person")
			is_valid_district = false
	if is_valid_district:
		for i in current_district.bodies:
			counted_bodies.append(i)
			#print(counted_bodies)
		make_new_district()
	else:
		#print("gameover")
		$failLabel.visible = true
		gameover = true
		yield(get_tree().create_timer(5.0), "timeout")
		$UI/PauseMenu.visible = true
		$UI/PauseMenu.call_deferred("popup")


func make_new_district():
	if not gameover:
		if current_district_num > 0 and not setting_up_new_board:
			var green_wins = false
			var purple_wins = false
			if current_district.district_purples > current_district.district_greens:
				purple_wins = true
				district_purples.append(current_district.district_purples+current_district.district_greens)
				district_greens.append(0)
			elif current_district.district_greens > current_district.district_purples:
				green_wins = true
				district_greens.append(current_district.district_purples+current_district.district_greens)
				district_purples.append(0)
			else:
				district_purples.append(0)
				district_greens.append(0)
			#$districtcount+str(current_district_num+1)
			if purple_wins:
				get_node("counts/districtcount"+str(current_district_num)).bbcode_text = str(current_district_num)+":  [color=#bf3fb3]"+str(district_purples[current_district_num-1])+"[/color]"
			elif green_wins:
				get_node("counts/districtcount"+str(current_district_num)).bbcode_text = str(current_district_num)+": [color=#83e04c]"+str(district_greens[current_district_num-1])+"[/color]"
			else:
				get_node("counts/districtcount"+str(current_district_num)).bbcode_text = str(current_district_num)+": -"
			count_totals()
		if current_district_num < total_districts and not setting_up_new_board: #still have districts to go
			current_district_num += 1
			current_district = districts[random.randi_range(0,districts.size()-1)].instance()
			current_district.position = Vector2(316,185)
			current_district.counted_bodies = counted_bodies
			add_child(current_district)
			current_district.z_index = VisualServer.CANVAS_ITEM_Z_MIN+2 #0 #VisualServer.CANVAS_ITEM_Z_MAX
			district_children.append(current_district)
	#		for i in current_district.get_children():
	#			i.z_index = 0


