Concord.component("typewriter_timer")

Concord.component("typewriter", function(c, every)
	assert(type(every) == "number", every)
	c.every = every
end)

Concord.component("reflowprint", function(c, width, alignment, speed)
	assert(type(width) == "number", width)
	assert(type(alignment) == "string", alignment)
	if speed then
		assert(type(speed) == "number", speed)
	end
	c.width = width
	c.alignment = alignment
	c.dt = 0
	c.current = 1

	c.speed = speed or 2.5
end)
