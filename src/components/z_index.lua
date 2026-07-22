Concord.component("z_index", function(c, z, sortable)
	assert(type(z) == "number", z)
	if sortable then
		assert(type(sortable) == "boolean", sortable)
	end
	c.value = z
	c.sortable = sortable ~= false
end)
