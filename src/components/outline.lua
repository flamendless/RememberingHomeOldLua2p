Concord.component("outline")

Concord.component("outline_val", function(c, size)
	if not (type(size) == "number") then
		error('Assertion failed: type(size) == "number"')
	end
	c.value = size
end)
