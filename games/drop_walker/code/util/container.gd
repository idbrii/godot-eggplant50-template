# Invert a dictionary so all of its keys are now its values and vice versa.
static func invert_dict(d):
	var inv = {}
	for key in d:
		var item = d[key]
		inv[item] = key
	return inv
