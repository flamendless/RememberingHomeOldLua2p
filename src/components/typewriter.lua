Concord.component("typewriter_timer")

Concord.component("typewriter", function(c, every)
	if type(every) ~= "number" then
		error('Assertion failed: type(every) == "number"')
	end
	c.every = every
end)

Concord.component("reflowprint", function(c, width, alignment, speed)
	if type(width) ~= "number" then
		error('Assertion failed: type(width) == "number"')
	end
	if type(alignment) ~= "string" then
		error('Assertion failed: type(alignment) == "string"')
	end
	if speed then
		if type(speed) ~= "number" then
			error('Assertion failed: type(speed) == "number"')
		end
	end
	c.width = width
	c.alignment = alignment
	c.dt = 0
	c.current = 1

	c.speed = speed or 2.5
end)
