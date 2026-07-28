Concord.component("angle", function(c, radius, angle)
	assert:type(radius, "number")
	assert:type_or_nil(angle, "number")
	c.radius = radius
	c.angle = angle or 0
	c.orig_radius = radius
end)

Concord.component("angular_speed", function(c, speed, dir)
	assert:type(speed, "number")
	assert:type(dir, "number")
	c.speed = speed
	c.dir = dir
end)
