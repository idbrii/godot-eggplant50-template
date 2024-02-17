extends Node2D


# Declare member variables here. Examples:
var type


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var t = randf()
    if t < .4:
        type = "atk"
        self.modulate = Color("#e14141")
    elif t < .8:
        type = "def"
        self.modulate = Color("#3898ff")
    else:
        type = "extra"
        self.modulate = Color("#bf3fb3")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
