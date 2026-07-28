Concord.component("z_index", function(c, z, sortable)
	assert:type(z, "number")
	assert:type_or_nil(sortable, "boolean")
	c.value = z
	c.sortable = sortable ~= false
end)
