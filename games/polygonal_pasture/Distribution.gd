extends Node2D

func on_shape_ready_to_collect(shape: RigidBody2D):
	var collector : AnimatedSprite = $CollectorOne.duplicate()
	add_child(collector)

	var tween_duration = 1 + randi() % 4
	var go_get = get_tree().create_tween()
	var go_to = Vector2(shape.global_position.x, collector.global_position.y)
	go_get.tween_property(collector, 'global_position', go_to, tween_duration*0.33)
	go_get.set_ease(Tween.EASE_IN)
	var fade_in = get_tree().create_tween()
	fade_in.tween_property(collector, 'modulate', Color('#ffffffff'), 0.3)

	yield(go_get, 'finished')

	collector.flip_h = true
	var leave_floor = get_tree().create_tween()
	leave_floor.tween_property(collector, 'global_position', Vector2(375, collector.global_position.y), tween_duration*0.66)
	leave_floor.set_ease(Tween.EASE_OUT)

	var shape_exit = get_tree().create_tween()
	shape_exit.tween_property(shape, 'global_position', Vector2(375, shape.global_position.y), tween_duration*0.66)
	shape_exit.set_ease(Tween.EASE_OUT)

	var fade_out1 = get_tree().create_tween()
	fade_out1.tween_property(collector, 'modulate', Color('#00ffffff'), tween_duration*0.6)
	var fade_out2 = get_tree().create_tween()
	fade_out2.tween_property(shape, 'modulate', Color('#00ffffff'), tween_duration*0.6)

	yield(leave_floor, 'finished')

	remove_child(collector)
