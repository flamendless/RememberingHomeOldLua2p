Concord.component("gravity", function(c, gravity)
	if type(gravity) ~= "number" then
		error('Assertion failed: type(gravity) == "number"')
	end
	c.value = gravity
end)
