Concord.component("lighter_flame", function(c, power)
	assert:type(power, "number")
	c.power = power
	c.orig_power = power
end)
