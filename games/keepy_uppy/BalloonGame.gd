extends Node2D

enum GameState {
	KEEPING_UP,
	FLOOR_TOUCHED
}

var time_kept_up
var game_state = GameState.KEEPING_UP

func _ready() -> void:
	time_kept_up = Time.get_ticks_msec()
	$Balloon.connect('touch_update', self, 'on_touch_update')
	$LilRobo.connect('stick_combo_update', self, 'on_stick_combo_update')
	$LilRobo.connect('head_combo_update', self, 'on_head_combo_update')
	$Balloon.connect('balloon_popped', self, 'on_balloon_pop')
	$Balloon.connect('floor_touched', $LilRobo, 'on_floor_touched')
	$Balloon.connect('floor_touched', self, 'on_floor_touched')

func _process(delta: float) -> void:
	if game_state == GameState.KEEPING_UP and has_node('Balloon'):
		var now = Time.get_ticks_msec()
		$UI/Status.update_timer((now - time_kept_up) / 1000.0)

func on_touch_update(count):
	if game_state == GameState.KEEPING_UP:
		$UI/Status.on_touch_update(count)

func on_stick_combo_update(count):
	if game_state == GameState.KEEPING_UP:
		$UI/Status.on_stick_combo_update(count)

func on_head_combo_update(count):
	if game_state == GameState.KEEPING_UP:
		$UI/Status.on_head_combo_update(count)

func on_balloon_pop(balloon):
	remove_child(balloon)
	$UI/PauseMenu.show()

func on_floor_touched():
	game_state = GameState.FLOOR_TOUCHED
	$UI/PauseMenu.show()
