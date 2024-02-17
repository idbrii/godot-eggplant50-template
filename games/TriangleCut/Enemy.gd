extends Node2D


# Declare member variables here. Examples:
var hp: int = 10 setget set_hp
var attacking_for: int = 3 setget set_attacking_for


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.hp = 10
    self.attacking_for = 3
    randomize()

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
