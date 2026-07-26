Concord.component("lighter_flame")

Concord.component("lighter_wick_offset", function(c, x, y)
	if x then
		assert(type(x) == "number", x)
	end
	if y then
		assert(type(y) == "number", y)
	end

	c.x = x or 0
	c.y = y or 0
	c.power = 0
	c.orig_x = c.x
	c.orig_y = c.y
	c.orig_power = c.power
end)
