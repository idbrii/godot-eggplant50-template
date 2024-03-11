extends Node2D


var bodies = []
var district_purples = 0
var district_greens = 0
var active = true
var current_timer_scale = 25
var counted_bodies = []


func _ready():
	$timerBox.scale.x = current_timer_scale
	$timerBox.scale.y = current_timer_scale
	$timerBox.z_index = VisualServer.CANVAS_ITEM_Z_MIN
#	$timerBox/ColorRect2.rect_size.y = 5/current_timer_scale
#	$timerBox/ColorRect2.rect_size.y = 5/current_timer_scale
	
	var i = 0
	while i < 100:
		yield(get_tree().create_timer(0.125), "timeout")
		if active and not get_parent().get_node("UI/PauseMenu").visible:
			i += 1
			current_timer_scale -= 0.25
			$timerBox.scale.x = current_timer_scale
			$timerBox.scale.y = current_timer_scale
#			$timerBox/ColorRect.rect_size.y = 5/current_timer_scale
#			$timerBox/ColorRect2.rect_size.y = 5/current_timer_scale
			if i == 99:
				active = false
				$timerBox.visible = false
				get_parent()._district_sending_timeout()
				break
		elif active and get_parent().get_node("UI/PauseMenu").visible:
			pass
		else:
			break
		

func _parent_sending_deactivate():
	active = false
	$timerBox.visible = false


func _on_Area2D_body_entered(body):
	bodies.append(body)
#	print(body.name)
	if body.name == "greenP":
		district_greens += 1
	elif body.name == "purpleP":
		district_purples += 1
	else:
		print("name not recognized")
	
	var is_valid = true
	for i in bodies:
		if counted_bodies.has(i):
			$timerBox/ColorRect.color = "#e14141" #modulate = "#e14141"
			$ColorRect.color = "#e14141" 
			$ColorRect2.color = "#e14141" 
			$ColorRect3.color = "#e14141" 
			is_valid = false
		elif is_valid:
			$timerBox/ColorRect.color = "#ffffff" #modulate = "#ffffff"
			$ColorRect.color = "#ffffff" 
			$ColorRect2.color = "#ffffff" 
			$ColorRect3.color = "#ffffff" 
			#print("error recounted person")
#	print(district_greens)
#	print(district_purples)


func _on_Area2D_body_exited(body):
	if bodies.has(body):
		#print(body.name)
		if body.name == "greenP":
			district_greens -= 1
		elif body.name == "purpleP":
			district_purples -= 1
		else:
			print("name not recognized")
		bodies.erase(body)
		#print(bodies.size())
	else:
		print("uhoh")
	if district_greens <= 0 and district_purples <= 0:
		$timerBox/ColorRect.color = "#e14141" #modulate = "#e14141"
		$ColorRect.color = "#e14141" 
		$ColorRect2.color = "#e14141" 
		$ColorRect3.color = "#e14141" 
	else:
		var is_valid = true
		for i in bodies:
			if counted_bodies.has(i):
				$timerBox/ColorRect.color = "#e14141" #modulate = "#e14141"
				$ColorRect.color = "#e14141" 
				$ColorRect2.color = "#e14141" 
				$ColorRect3.color = "#e14141" 
				is_valid = false
			elif is_valid:
				$timerBox/ColorRect.color = "#ffffff" #modulate = "#ffffff"
				$ColorRect.color = "#ffffff" 
				$ColorRect2.color = "#ffffff" 
				$ColorRect3.color = "#ffffff" 
#	print(district_greens)
#	print(district_purples)
