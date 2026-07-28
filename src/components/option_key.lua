Concord.component("option_key", function(c, id, page)
	assert:type(id, "number")
	assert:type(page, "number")
	c.id = id
	c.page = page
end)

Concord.component("option_disabled")
