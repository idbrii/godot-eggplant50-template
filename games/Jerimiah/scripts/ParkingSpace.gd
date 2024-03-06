extends Node2D

export(NodePath) var worldPath
export(NodePath) var parkingMeterPath
export(NodePath) var violationsListPath
export(NodePath) var fineAmountPath
export(NodePath) var citationNoticePath
onready var world := get_node(worldPath) as Node2D
onready var parkingMeter := get_node(parkingMeterPath) as Node2D
onready var violationsList := get_node(violationsListPath) as RichTextLabel
onready var fineAmount := get_node(fineAmountPath) as RichTextLabel
onready var citationNotice := get_node(citationNoticePath) as CenterContainer

export(float) var maxWaitTime = 10.0
export(float) var maxParkTime = 120.0

signal revenue_affected(newRevenue)

var hasCar = false
var car: int
var actualViolations = []
var violations = []
var citationIssued = false

# show points track score ($earned)
# add a few characters to walk to/from cars
# 

func _ready():
	wait_for_next_car()


func wait_for_next_car():
	get_tree().create_timer(rand_range(0.0, maxWaitTime), false).connect("timeout", self, "car_enters")


func car_enters():
	hasCar = true
	car = randi() % 4 + 1
	get_node("Car/Car" + String(car)).visible = true
	$Car.visible = true
	var desiredParkingTime = rand_range(10.0, 120.0)

	var willPay = rand_range(0.0, 4.0) < 3.0

	if willPay:
		parkingMeter.add_time(rand_range(desiredParkingTime - 10.0, desiredParkingTime + 10.0))
		parkingMeter.timer.connect('timeout', self, "new_actual_violation", [{ 'type': 'meter payment', "fine": 10.00 }])
	else:
		if parkingMeter.timer.time_left <= 0.0:
			actualViolations.append({ 'type': 'meter payment', "fine": 10.00 })
		else:
			parkingMeter.timer.connect('timeout', self, "new_actual_violation", [{ "type": "meter payment", "fine": 10.00}])

	$parkingTimer.start(desiredParkingTime)


func new_actual_violation(violation):
	if hasCar:
		actualViolations.append(violation)


func car_exits():
	print(self.name)
	
	if actualViolations.size() > 0:
		if not citationIssued:
			print('failed - missed citation')
			$ParkingSpaceArea/AnimationPlayer.play('fail')
			emit_signal("revenue_affected", -10.0)
		else:
			var extra = []
			var accurateViolations = []

			for i in violations.size():
				var found = false

				for j in actualViolations.size():
					if violations[i].type == actualViolations[j].type:
						accurateViolations.append(actualViolations[j])
						found = true
						continue
				if not found:
					extra.append(violations[i])
			if actualViolations.size() != accurateViolations.size() or extra.size() > 0:
				$ParkingSpaceArea/AnimationPlayer.play("fail")
				emit_signal("revenue_affected", -10.0)
				print('fail - inaccurate citation' )
				print('missing ', actualViolations)
				print('extra ', extra)
			else:
				$ParkingSpaceArea/AnimationPlayer.play("success")
				emit_signal("revenue_affected", 10.0)
				print('success - correct citation')

	else:
		if not citationIssued:
			print('success - valid parking')
		else:
			$ParkingSpaceArea/AnimationPlayer.play("fail")
			emit_signal("revenue_affected", -10.0)
			print('fail - no violation')
	
	hasCar = false
	$Car.visible = false
	get_node("Car/Car" + String(car)).visible = false
	get_node("Car/Car" + String(car) + "/Ticket").visible = false
	actualViolations = []
	violations = []
	citationIssued = false
	
	if world.currentParkingSpace.name == self.name:
		update_violations()
	# grade car and report score
	# reset all the stuff
	# set some amount of time until the next car shows up
	wait_for_next_car()

func toggle_violation(violation):
	var existingViolation = -1
	for i in violations.size():
		if violation.type == violations[i].type:
			existingViolation = i

	if existingViolation >= 0:
		violations.remove(existingViolation)
	else:
		violations.append(violation)
	
	update_violations()

func update_violations():
	var violationsText = ""
	var fines: float = 0.0
	for violation in violations:
		violationsText = violationsText + "- " + violation.type + "\n"
		fines += violation.fine
	
	violationsList.parse_bbcode(violationsText)
	fineAmount.parse_bbcode("$" + String(fines))
	
	if citationIssued:
		citationNotice.visible = true
	else:
		citationNotice.visible = false


func enters_space(area):
	update_violations()
	world.currentParkingSpace = self


func issue_citation():
	if not violations.size():
		return

	citationIssued = true
	get_node("Car/Car" + String(car) + "/Ticket").visible = true
	update_violations()

