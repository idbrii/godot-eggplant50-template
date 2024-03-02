
static func flat_clamp(v: Vector3, max_length: float) -> Vector3:
	var flat := v
	flat.y = 0
	flat = flat.limit_length(max_length)
	flat.y = v.y
	return flat


static func vec3_from_xz(v: Vector2) -> Vector3:
	return Vector3(v.x, 0, v.y)


static func xz_from_vec3(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)


static func assign_xz(dest: Vector3, src: Vector3) -> Vector3:
	dest.x = src.x
	dest.z = src.z
	return dest


# Could be vec2 or vec3
static func deadzone(input, current, max_len):
	var delta = current - input
	delta = delta.limit_length(max_len)
	return input + delta


static func is_zero_approx(v):
	return v.length_squared() < 0.01
