Concord.component("ui_element")

Concord.component("layer", function(c, id, n)
	assert:type(id, "string")
	assert:type_or_nil(n, "number")
	c.id = id
	c.n = n or 0
end)
