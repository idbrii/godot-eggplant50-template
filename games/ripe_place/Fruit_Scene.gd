extends Node2D

export(bool) var is_a_fruit = true
export(float) var highlight_scale = 1.1
export(int) var ripeness = 0
export(Dictionary) var nutritions_for_ripeness_categories

var fruit_sprite: Sprite

var colors_for_ripeness_categories = {
	'unripe': Color(1.0, 1.0, 1.0),
	'ripe': Color(1.0, 1.0, 0.5),
	'overripe': Color(0.6, 0.6, 0.6)
}

# Called when the node enters the scene tree for the first time.
func _ready():
	fruit_sprite = self.get_node("FruitBody/Sprite")
	update_color()

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

func harvest(harvester):
	var category = get_category_for_ripeness(ripeness)
	var nutrition = nutritions_for_ripeness_categories[category]
	harvester.change_nutrition(nutrition)
	self.get_parent().remove_child(self)

func _on_ripenessTimer_timeout():
	ripeness += 1
	update_color()
	var category = get_ripeness_category()	
	if category == 'decayed':
		start_explode()

func update_color():
	var category = get_ripeness_category()
	var color = colors_for_ripeness_categories.get(category)
	if color:
		fruit_sprite.modulate = color
		
func start_explode():
	$FruitBody/AnimatedSprite.visible = true
	$FruitBody/Sprite.visible = false
	$FruitBody/AnimatedSprite.playing = true
	
func finish_explode():
	self.get_parent().remove_child(self)
	
func _on_AnimatedSprite_animation_finished():
	finish_explode()

func get_category_for_ripeness(r: int):
	if r >= 0 && r <= 2:
		return 'unripe'
	if r >= 3 && r <= 4:
		return 'ripe'
	if r >= 5 && r <= 7:
		return 'overripe'
	return 'decayed'

func get_ripeness_category():
	return get_category_for_ripeness(ripeness)
