Concord.component("outline")

Concord.component("outline_val", function(c, size)
	assert:type(size, "number")
	c.value = size
end)
