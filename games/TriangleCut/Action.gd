extends Node2D


# Declare member variables here. Examples:
var type
var sword_tex = preload("res://games/TriangleCut/sword.png")
var shield_tex = preload("res://games/TriangleCut/shield.png")
var triangle_tex = preload("res://games/TriangleCut/triangle_cut.png")

var action_particle_scene = preload("res://games/TriangleCut/ActionParticle.tscn")

var type_to_frame = {"atk": 0, "def":1, "extra":2}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $AnimationPlayer.play("RESET")
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
    yield(get_tree().create_timer(rand_range(0, 1.0)), "timeout")
    $AnimationPlayer.play("spawn")

func activate():
    $AnimationPlayer.play("activate")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass

func create_particle():
    var particle = action_particle_scene.instance()
    get_parent().add_child(particle)
#    particle.texture.current_frame = type_to_frame[type]
    particle.texture = $Sprite.texture
    particle.global_position = global_position
    particle.emitting = true
