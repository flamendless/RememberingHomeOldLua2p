Concord.component("line_of_sight", function(c, value)
	assert(type(value) == "number", value)
	c.value = value
end)
