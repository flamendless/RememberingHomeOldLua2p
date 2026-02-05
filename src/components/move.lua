Concord.component("move_by", function(c, x, y, duration, delay)
	if type(x) ~= "number" then
		error('Assertion failed: type(x) == "number"')
	end
	if type(y) ~= "number" then
		error('Assertion failed: type(y) == "number"')
	end
	if type(duration) ~= "number" then
		error('Assertion failed: type(duration) == "number"')
	end
	if delay then
		if type(delay) ~= "number" then
			error('Assertion failed: type(delay) == "number"')
		end
	end
	c.x = x
	c.y = y
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("move_repeat")

Concord.component("move_to_x", function(c, x_pos, duration, delay)
	if type(x_pos) ~= "number" then
		error('Assertion failed: type(x_pos) == "number"')
	end
	if type(duration) ~= "number" then
		error('Assertion failed: type(duration) == "number"')
	end
	if delay then
		if type(delay) ~= "number" then
			error('Assertion failed: type(delay) == "number"')
		end
	end
	c.target_x = x_pos
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("move_to_original", function(c, duration, delay)
	if type(duration) ~= "number" then
		error('Assertion failed: type(duration) == "number"')
	end
	if delay then
		if type(delay) ~= "number" then
			error('Assertion failed: type(delay) == "number"')
		end
	end
	c.duration = duration
	c.delay = delay or 0
end)
