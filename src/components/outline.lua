Concord.component("outline")

Concord.component("outline_val", function(c, size)
	assert(type(size) == "number", size)
	c.value = size
end)
