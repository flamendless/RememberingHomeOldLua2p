Concord.component("move_by", function(c, x, y, duration, delay)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	assert(type(duration) == "number", duration)
	if delay then
		assert(type(delay) == "number", delay)
	end
	c.x = x
	c.y = y
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("move_repeat")

Concord.component("move_to_x", function(c, x_pos, duration, delay)
	assert(type(x_pos) == "number", x_pos)
	assert(type(duration) == "number", duration)
	if delay then
		assert(type(delay) == "number", delay)
	end
	c.target_x = x_pos
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("move_to_original", function(c, duration, delay)
	assert(type(duration) == "number", duration)
	if delay then
		assert(type(delay) == "number", delay)
	end
	c.duration = duration
	c.delay = delay or 0
end)
