extends Node2D

export(bool) var is_a_fruit = true
export(float) var highlight_scale = 1.1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func highlightFruit():
	var fruit_sprite: Sprite = self.get_node("FruitBody/Sprite")
	fruit_sprite.set_scale(fruit_sprite.get_scale() * highlight_scale)
	$FruitBody/GlowPolygon.visible = true
	
func unhighlightFruit():
	var fruit_sprite: Sprite = self.get_node("FruitBody/Sprite")
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
