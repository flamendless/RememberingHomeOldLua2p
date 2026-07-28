Concord.component("light", function(c, light_shape, power)
	assert:type(power, "number")
	assert((power >= 0 and power <= 4), power)
	c.light_shape = light_shape
	c.power = power
end)

Concord.component("light_timer", function(c, timer)
	assert:type_or_nil(timer, "number")
	c.value = timer or 0
	c.orig_value = c.value
end)

Concord.component("light_flicker", function(c, off_chance)
	assert:type(off_chance, "number")
	c.off_chance = off_chance
end)
