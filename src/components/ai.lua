Concord.component("line_of_sight", function(c, value)
	if not (type(value) == "number") then
		error('Assertion failed: type(value) == "number"')
	end
	c.value = value
end)
