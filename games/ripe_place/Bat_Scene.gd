extends Node2D
#signal overlapping

export(Vector2) var screen_size
export(int) var move_size
export(int) var initial_nutrition
export(int) var move_cost

var hud
var covered_fruit_scene: PackedScene
var nutrition

func _ready():
	hud = self.get_parent().get_node('hud');
	hud.connect('start_game', self, 'reset')
	reset()
	
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
	hud.update_score(self.nutrition)
	if self.nutrition < 1:
		hud.show_game_over()

func reset():
	self.nutrition = initial_nutrition
	change_nutrition(0)

func _on_nutrition_timer_timeout():
	change_nutrition(-1)
