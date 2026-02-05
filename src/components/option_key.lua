Concord.component("option_key", function(c, id, page)
	if type(id) ~= "number" then
		error('Assertion failed: type(id) == "number"')
	end
	if type(page) ~= "number" then
		error('Assertion failed: type(page) == "number"')
	end
	c.id = id
	c.page = page
end)

Concord.component("option_disabled")
