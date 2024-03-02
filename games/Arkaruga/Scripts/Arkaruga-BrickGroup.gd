extends Area2D

export var baseMoveSpeed = 0.5
export var maxMoveSpeedModifier = 5.0

onready var _manager : Node2D = get_tree().get_nodes_in_group("Manager")[0]
onready var _collisionShape : CollisionShape2D = $CollisionShape2D
onready var _visibilityNotifier : VisibilityNotifier2D = $VisibilityNotifier2D

var _isVisible = false	

func _ready():
	# move our visibility notifier up to the top of the area so we don't destroy things too early
	_visibilityNotifier.position.y = _collisionShape.position.y * 2
	

func _process(delta):
	_updateMovement(delta)
	
func _updateMovement(delta: float):
	var movementSpeed = baseMoveSpeed
	if _manager != null:
		if !_manager.getAnyBallsActive():
			# don't move while there are no balls
			return
		
		movementSpeed *= lerp(1.0, maxMoveSpeedModifier, _manager.getSpeedModifierRatio())
		
	position.y += movementSpeed * delta * 5

func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	if _isVisible:
		_isVisible = false
		queue_free()


func _on_VisibilityNotifier2D_viewport_entered(_viewport):
	_isVisible = true


func _on_BrickGroup_area_exited(area):
	if (area.is_in_group("BrickSpawnArea") && _manager != null):
		_manager.onBrickSpawnAreaClear()
		
