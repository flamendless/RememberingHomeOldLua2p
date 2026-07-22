Concord.component("custom_renderer", function(c, value)
	assert(type(value) == "string", value)
	c.value = value
end)
