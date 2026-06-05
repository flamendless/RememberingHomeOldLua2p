Concord.component("glow_disabled")
Concord.component("glow_blocker")
Concord.component("glow_blocker_disabled")

Concord.component("billboard_glow", function(c, intensity, size)
	assert(type(intensity) == "number")
	assert(type(size) == "number")
	c.intensity = intensity
	c.size = size
	c.orig_intensity = c.intensity
end)

Concord.component("glow_flicker", function(c, chance, offset)
	assert(type(chance) == "number")
	assert(type(offset) == "number")
	c.chance = chance
	c.offset = offset
end)

Concord.component("glow_pulse", function(c, speed, amplitude)
	assert(type(speed) == "number")
	assert(type(amplitude) == "number")
	c.speed = speed
	c.amplitude = amplitude
	c.time = 0
end)

Concord.component("glow_group", function(c, id)
	assert(type(id) == "string")
	c.id = id
end)
