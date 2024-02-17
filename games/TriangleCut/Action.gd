extends Node2D


# Declare member variables here. Examples:
var type
var sword_tex = preload("res://games/TriangleCut/sword.png")
var shield_tex = preload("res://games/TriangleCut/shield.png")
var triangle_tex = preload("res://games/TriangleCut/triangle_cut.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var t = randf()
    if t < .4:
        type = "atk"
        $Sprite.texture = sword_tex
    elif t < .8:
        type = "def"
        $Sprite.texture = shield_tex
    else:
        type = "extra"
        $Sprite.texture = triangle_tex


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
