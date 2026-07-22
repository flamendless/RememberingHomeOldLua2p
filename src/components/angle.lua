Concord.component("angle", function(c, radius, angle)
	assert(type(radius) == "number", radius)
	if angle then
		assert(type(angle) == "number", angle)
	end
	c.radius = radius
	c.angle = angle or 0
	c.orig_radius = radius
end)

Concord.component("angular_speed", function(c, speed, dir)
	assert(type(speed) == "number", speed)
	assert(type(dir) == "number", dir)
	c.speed = speed
	c.dir = dir
end)
