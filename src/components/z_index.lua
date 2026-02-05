Concord.component("z_index", function(c, z, sortable)
	if type(z) ~= "number" then
		error('Assertion failed: type(z) == "number"')
	end
	if sortable then
		if type(sortable) ~= "boolean" then
			error('Assertion failed: type(sortable) == "boolean"')
		end
	end
	c.value = z
	c.sortable = sortable ~= false
end)
