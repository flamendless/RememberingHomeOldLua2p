Concord.component("custom_renderer", function(c, value)
	assert:type(value, "string")
	c.value = value
end)
