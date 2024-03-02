static func ok(err):
	assert(err == OK)

static func was_true(err):
	assert(err == true)

static func ignore(_err):
	pass
