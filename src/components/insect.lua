Concord.component("bug")
Concord.component("ant")
Concord.component("firefly")

Concord.component("fly", function (c, radius)
	if not (type(radius) == "number") then
		error('Assertion failed: type(radius) == "number"')
	end
	c.max_radius = radius * (1.1 + love.math.random() * 0.4)
	c.pull = radius * love.math.random(2, 4)
	c.vel_x = (love.math.random() - 0.5) * 7
	c.vel_y = (love.math.random() - 0.5) * 7
	c.turn_timer = 0
	c.sharp_timer = 0
end)

Concord.component("scatter_away_from", function (c, e_target, distance, speed)
	assert(e_target.__isEntity)
	assert(type(distance) == "number")
	assert(type(speed) == "number")
	e_target:ensure("key")
	c.key = e_target.key.value
	c.distance = distance
	c.speed = speed
	c.is_overlap = false
	c.escape_target = nil
end)
