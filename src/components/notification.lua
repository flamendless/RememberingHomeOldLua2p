Concord.component("notification", function(c, id)
	assert(type(id) == "string", id)
	c.value = id
end)
