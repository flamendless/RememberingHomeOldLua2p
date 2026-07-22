Concord.component("gravity", function(c, gravity)
	assert(type(gravity) == "number", gravity)
	c.value = gravity
end)
