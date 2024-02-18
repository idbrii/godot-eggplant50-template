extends Node2D


# Declare member variables here. Examples:
var hp: int = 10 setget set_hp
var attacking_for: int = 3 setget set_attacking_for
var colors = [
    Color("#17111a"),
    Color("#372538"),
    Color("#7a213a"),
    Color("#e14141"),
    Color("#ffa070"),
    Color("#c44d29"),
    Color("#ffbf36"),
    Color("#fff275"),
    Color("#753939"),
    Color("#cf7957"),
    Color("#ffd1ab"),
    Color("#39855a"),
    Color("#83e04c"),
    Color("#dcff70"),
    Color("#243b61"),
    Color("#3898ff"),
    Color("#6eeeff"),
    Color("#682b82"),
    Color("#bf3fb3"),
    Color("#ff80aa"),
    Color("#3e375c"),
    Color("#7884ab"),
    Color("#b2bcc2"),
    Color("#ffffff"),
   ]
var gradient = preload("res://games/TriangleCut/gradient.tres")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.hp = 10
    self.attacking_for = 3
    randomize()
    colors.shuffle()
    gradient.gradient.colors = colors.slice(0, 6)
    $ColorRect.material.set_shader_param("x_dir", rand_range(0.1, 5.0))
    $ColorRect.material.set_shader_param("y_dir", rand_range(0.1, 5.0))
    $Eyes/Whites/Pupils.modulate = colors[0]
    $Eyes/Whites.material.set_shader_param("fac", rand_range(-0.5, 0.5))

func set_attacking_for(new_val):
    attacking_for = new_val
    $Label.text = "HP: "+str(hp)+"\nATK: "+str(attacking_for)
    
func set_hp(new_val):
    hp = new_val
    $Label.text = "HP: "+str(hp)+"\nATK: "+str(attacking_for)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass

func next_turn():
    # update attack
    self.attacking_for = round(rand_range(1, 7))