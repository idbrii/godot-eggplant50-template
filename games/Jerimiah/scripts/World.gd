extends Node2D

export(Color) var HIGHLIGHT_COLOR = Color('#c44d29')
export(Color) var NORMAL_COLOR = Color('#17111a')
export(int) var speed = 2

var controlStreetPane = true
var currentDetailType
var currentParkingSpace: Node2D
var totalRevenue = 0

func _ready():
	$StreetView/Border.border_color = HIGHLIGHT_COLOR
	$StreetView.z_index = 1
	$DetailView/Border.border_color = NORMAL_COLOR
	$CitationView/Border.border_color = NORMAL_COLOR


func _physics_process(delta):
	if controlStreetPane:
		handle_street_pane()
	else:
		handle_detail_pane()


func handle_street_pane():
	var move_x := Input.get_axis("move_left", "move_right")
	$StreetView/MeterAttendant.move_and_collide(Vector2(speed * move_x, 0))
	if move_x < 0:
		$StreetView/MeterAttendant/AnimatedSprite.flip_h = true
	if move_x > 0:
		$StreetView/MeterAttendant/AnimatedSprite.flip_h = false
		
	if move_x == 0:
		$StreetView/MeterAttendant/AnimatedSprite.play("idle")
	else:
		$StreetView/MeterAttendant/AnimatedSprite.play("run")
	
	if Input.is_action_just_pressed("action1"):
		var overlapping = $StreetView/MeterAttendant/interacts.get_overlapping_areas()
		if overlapping:
			var overlapped = overlapping[0].get_parent()
			if 'detailType' in overlapped:
				if overlapped.detailType == 'windshield':
					currentParkingSpace.issue_citation()
				else:
					activate_detail_view(overlapped)
	
func handle_detail_pane():
	if Input.is_action_just_pressed("action1"):
		if currentDetailType == 'meter' && not currentParkingSpace.citationIssued:
			currentParkingSpace.toggle_violation({ 'type': 'meter payment', 'fine': 10.00 })

	if Input.is_action_just_pressed("action2"):
		activate_street_view()

func activate_street_view():
	controlStreetPane = true
	$StreetView/Border.border_color = HIGHLIGHT_COLOR
	$StreetView.z_index = 1
	$DetailView/Border.border_color = NORMAL_COLOR
	$DetailView.z_index = 0
	
	if currentDetailType == 'meter':
		$DetailView/Meter.visible = false
		
	currentDetailType = null
	$CitationView/Citation/TogglePrompt.visible = false
	$DetailView/InspectPrompt.visible = true
	$DetailView/ToggleExit.visible = false
	
func activate_detail_view(parentNode):
	controlStreetPane = false
	$DetailView/Border.border_color = HIGHLIGHT_COLOR
	$DetailView.z_index = 1
	$StreetView/Border.border_color = NORMAL_COLOR
	$StreetView.z_index = 0
	
	currentDetailType = parentNode.detailType
	
	if currentDetailType == 'meter':
		$StreetView/MeterAttendant/AnimatedSprite.play("idle")
		$DetailView/Meter.visible = true
		if not currentParkingSpace.citationIssued:
			$CitationView/Citation/TogglePrompt.visible = true
		$DetailView/InspectPrompt.visible = false
		$DetailView/ToggleExit.visible = true
		$DetailView/Meter.timer = parentNode.timer
		return
		
	activate_street_view()


func meter_attendant_area_entered(area):
	var parent = area.get_parent()
	if 'detailType' in parent && currentParkingSpace:
		if parent.detailType == 'windshield' && currentParkingSpace.hasCar && not currentParkingSpace.citationIssued && currentParkingSpace.violations.size() > 0:
			$CitationView/Citation/CitationPrompt.visible = true
		if parent.detailType == 'meter':
			$DetailView/InspectPrompt.visible = true



func meter_attendant_area_exited(area):
	var parent = area.get_parent()
	if 'detailType' in parent:
		if parent.detailType == 'windshield':
			$CitationView/Citation/CitationPrompt.visible = false
		if parent.detailType == 'meter':
			$DetailView/InspectPrompt.visible = false


func revenue_affected(newRevenue):
	totalRevenue += newRevenue
	$CitationView/Revenue/HBoxContainer/Revenue.text = "$" + String(totalRevenue)
	
	if newRevenue <= 0.0:
		$CitationView/Revenue/Cash/AnimationPlayer.play("subRevenue")
	else:
		$CitationView/Revenue/Cash/AnimationPlayer.play("addRevenue")
