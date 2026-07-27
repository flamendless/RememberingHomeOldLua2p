Concord.component("lighter_flame", function(c, power)
	assert(type(power) == "number", power)
	c.power = power
	c.orig_power = power
end)
