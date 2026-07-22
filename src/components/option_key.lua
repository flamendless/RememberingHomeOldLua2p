Concord.component("option_key", function(c, id, page)
	assert(type(id) == "number", id)
	assert(type(page) == "number", page)
	c.id = id
	c.page = page
end)

Concord.component("option_disabled")
