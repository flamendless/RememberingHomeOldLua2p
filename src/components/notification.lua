Concord.component("notification", function(c, id)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	c.value = id
end)
