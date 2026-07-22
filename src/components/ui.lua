Concord.component("ui_element")

Concord.component("layer", function(c, id, n)
	assert(type(id) == "string", id)
	if n then
		assert(type(n) == "number", n)
	end
	c.id = id
	c.n = n or 0
end)
