Concord.component("angle", function(c, radius, angle)
	if not (type(radius) == "number") then
		error('Assertion failed: type(radius) == "number"')
	end
	if angle then
		if not (type(angle) == "number") then
			error('Assertion failed: type(angle) == "number"')
		end
	end
	c.radius = radius
	c.angle = angle or 0
	c.orig_radius = radius
end)

Concord.component("angular_speed", function(c, speed, dir)
	if not (type(speed) == "number") then
		error('Assertion failed: type(speed) == "number"')
	end
	if not (type(dir) == "number") then
		error('Assertion failed: type(dir) == "number"')
	end
	c.speed = speed
	c.dir = dir
end)
