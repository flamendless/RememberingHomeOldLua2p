Concord.component("gravity", function(c, gravity)
	if not (type(gravity) == "number") then
		error('Assertion failed: type(gravity) == "number"')
	end
	c.value = gravity
end)
