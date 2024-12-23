#~ class_name Random

# Random integer, inclusive.
static func integer(lower: int, upper: int) -> int:
	return randi() % upper + lower # godot3


# Random float, inclusive.
static func decimal(lower: float, upper: float) -> float:
	return randf() * (upper - lower) + lower # godot3


static func choose_value(list: Array):
	return list[choose_index(list)]


static func choose_index(list: Array):
	var i = integer(0, list.size() - 1)
	return i


static func _sum_weights(choices) -> float:
	var sum := 0.0
	for key in choices:
		var weight = choices[key]
		sum += weight
	return sum


# Usage:
#   weighted_choice({'epic': 1, 'rare': 3, 'common': 6})
static func weighted_choice(choices):
	var sum := _sum_weights(choices)
	var threshold := decimal(0, sum)
	for key in choices:
		var weight = choices[key]
		threshold -= weight
		if threshold <= 0:
			return key

	push_error("weighted_choice failed to return a value.")
	return null


# Generate a population of choices with the input count that matches the input
# choice distribution.
#
# Usage:
#   weighted_fill({'epic': 1, 'rare': 3, 'common': 6}, 10)
static func weighted_fill(choices, desired_count : int):
	var total_count := desired_count
	var weight_sum := _sum_weights(choices)
	var mult = total_count / weight_sum
	var population = []
	for key in choices:
		var weight = choices[key]
		var count = int(ceil(mult * weight))
		total_count -= count
		for i in count:
			population.append(key)

	population.shuffle()

	while population.size() > desired_count:
		population.pop_back()
	while population.size() < desired_count:
		population.append(weighted_choice(choices))

	population.shuffle()
	return population


static func test():
	var c = choose_value([1,2,3,4])
	assert(1 <= c)
	assert(c <= 4)
	var choices := {'epic': 1, 'rare': 3, 'common': 6}
	assert(choices[weighted_choice(choices)])
	var sum := _sum_weights(choices)
	var population = weighted_fill(choices, int(sum))
	printt(population)
	for key in choices:
		var weight = choices[key]
		assert(population.count(key) == weight)
	printt(weighted_fill({'epic': 1, 'rare': 3, 'common': 6}, 10))

# Add to run in gdscript interpreter.
#~ func _ready():
#~     test() # this will warn
