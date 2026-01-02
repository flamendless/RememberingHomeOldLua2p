local Concord = require("modules.concord.concord")

Concord.component("light", function(c, light_shape, power)
	if not (type(power) == "number") then
		error('Assertion failed: type(power) == "number"')
	end
	if not (power >= 0 and power <= 4) then
		error("Assertion failed: power >= 0 and power <= 4")
	end
	c.light_shape = light_shape
	c.power = power
end)

Concord.component("light_timer", function(c, timer)
	if timer then
		if not (type(timer) == "number") then
			error('Assertion failed: type(timer) == "number"')
		end
	end
	c.value = timer or 0
	c.orig_value = c.value
end)

Concord.component("light_flicker", function(c, off_chance)
	if not (type(off_chance) == "number") then
		error('Assertion failed: type(off_chance) == "number"')
	end
	c.off_chance = off_chance
end)
