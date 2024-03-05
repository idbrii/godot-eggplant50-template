extends Node2D

export(bool) var is_a_fruit = true
export(float) var highlight_scale = 1.1
export(int) var ripeness = 0
export(int) var rot_threshold = 3

var fruit_sprite: Sprite

var colors_for_ripenesses = {
	0: Color(1.0, 1.0, 1.0),
	1: Color(1.0, 0.8, 0.4),
	2: Color(0.6, 0.6, 0.6)
}

# Called when the node enters the scene tree for the first time.
func _ready():
	fruit_sprite = self.get_node("FruitBody/Sprite")

func highlightFruit():
	fruit_sprite.set_scale(fruit_sprite.get_scale() * highlight_scale)
	$FruitBody/GlowPolygon.visible = true
	
func unhighlightFruit():
	fruit_sprite.set_scale(fruit_sprite.get_scale() / highlight_scale)
	$FruitBody/GlowPolygon.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_FruitArea_area_entered(area):
#	print('area shape entered', area)
	var body_parent = area.get_parent()
	if body_parent.name == 'bat':
		highlightFruit()

func _on_FruitArea_area_exited(area):
	var body_parent = area.get_parent()
	if body_parent.name == 'bat':
		unhighlightFruit()

func harvest():
	self.get_parent().remove_child(self)

func _on_ripenessTimer_timeout():
	ripeness += 1
	var color = colors_for_ripenesses.get(ripeness)
	if color:
		fruit_sprite.modulate = color
	if ripeness >= rot_threshold:
		start_explode()

func start_explode():
	$FruitBody/AnimatedSprite.visible = true
	$FruitBody/AnimatedSprite.playing = true
	
func finish_explode():
	self.get_parent().remove_child(self)
	
func _on_AnimatedSprite_animation_finished():
	finish_explode()
