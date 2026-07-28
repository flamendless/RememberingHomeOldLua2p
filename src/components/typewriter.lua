Concord.component("typewriter_timer")

Concord.component("typewriter", function(c, every)
	assert:type(every, "number")
	c.every = every
end)

Concord.component("reflowprint", function(c, width, alignment, speed)
	assert:type(width, "number")
	assert:type(alignment, "string")
	assert:type_or_nil(speed, "number")
	c.width = width
	c.alignment = alignment
	c.dt = 0
	c.current = 1

	c.speed = speed or 2.5
end)
