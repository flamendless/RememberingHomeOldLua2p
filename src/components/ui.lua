Concord.component("ui_element")

Concord.component("layer", function(c, id, n)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if n then
		if not (type(n) == "number") then
			error('Assertion failed: type(n) == "number"')
		end
	end
	c.id = id
	c.n = n or 0
end)
