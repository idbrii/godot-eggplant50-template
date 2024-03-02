extends Control

export var lose_speed := 1.0
export var win_speed := 10.0
export var max_y_delta := 10.0

onready var template := $BlockTemplate as AnimatedSprite

var blocks := []
var time := 0.0
export var current_speed := 0.0


func _ready():
	for __ in range(10):
		var b = template.duplicate()
		blocks.append(b)
		$BlockRoot.add_child(b)
	template.visible = false
	visible = false

	#~ show_lose()  # For testing


func _process(dt):
	time += dt
	var n := float(blocks.size())
	var width := 200.0
	var delta = Vector2.RIGHT * width/2 / n
	var pos = -delta * n/2.0
	for i in range(n):
		var b = blocks[i]
		b.position = pos
		var x = 1 * current_speed + i/n
		b.position.y = sin(time * x) * max_y_delta
		pos += delta


func show_win():
	show_state("Win!", win_speed)
	$Sound/Win.play()


func show_lose():
	show_state("Lose...", lose_speed)
	$Sound/Lose.play()


func show_state(label, speed):
	$Label.text = label
	current_speed = speed
	visible = true
