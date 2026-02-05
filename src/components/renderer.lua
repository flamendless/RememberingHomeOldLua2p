Concord.component("custom_renderer", function(c, value)
	if type(value) ~= "string" then
		error('Assertion failed: type(value) == "string"')
	end
	c.value = value
end)
