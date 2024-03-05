extends Node2D
#signal overlapping

export(Vector2) var screen_size
export(int) var move_size
export(int) var nutrition
export(int) var move_cost

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var covered_fruit_scene: PackedScene

func _process(_delta):
	handle_bat_move()
	handle_bat_action()

func handle_bat_move():
	var x = 0
	var y = 0
	if Input.is_action_just_released("move_left"):
		x -= 1
	if Input.is_action_just_released("move_right"):
		x += 1
	if Input.is_action_just_released("move_up"):
		y -= 1
	if Input.is_action_just_released("move_down"):
		y += 1

	var move = Vector2(x * move_size, y * move_size)

	self.position += move
	self.position.x = clamp(self.position.x, 0, screen_size.x)
	self.position.y = clamp(self.position.y, 0, screen_size.y)

	if (move.length() > 0):
		change_nutrition(-move_cost)

func handle_bat_action():
	if Input.is_action_just_released("action1"):
		var intersecting_bodies = self.get_node("batArea2D").get_overlapping_bodies()
		print('colliding: ', intersecting_bodies)
		var fruits = []
		for body in intersecting_bodies:
			fruits.append(body.get_parent())
		for fruit in fruits:
			fruit.harvest(self)

func change_nutrition(delta: int):
	self.nutrition += delta
	self.get_parent().get_node('HUD').update_score(self.nutrition)
