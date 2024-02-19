extends AudioStreamPlayer


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    play_music()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass

func play_music():
    play()
    $fg_music.play()

func play_fg(dur: int):
    $Tween.interpolate_property($fg_music, "volume_db", -80, -12.951, 0.1, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
    $Tween.start()
    yield(get_tree().create_timer(0.24*dur), "timeout")
    $Tween.interpolate_property($fg_music, "volume_db", -12.951, -80, 0.1, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
    $Tween.start()
