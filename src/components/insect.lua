Concord.component("bug")
Concord.component("ant")
Concord.component("firefly")

Concord.component("fly", function(c, radius, motion)
	assert:type(radius, "number")
	assert:type(motion, "table")
	c.max_radius = radius * (1.1 + love.math.random() * 0.4)
	c.pull = radius * love.math.random(motion.pull_radius_min, motion.pull_radius_max)
	c.max_speed = motion.max_speed
	c.max_speed_var = motion.max_speed_var
	c.sharp_impulse = motion.sharp_impulse
	c.vel_x = (love.math.random() - 0.5) * motion.initial_vel
	c.vel_y = (love.math.random() - 0.5) * motion.initial_vel
	c.turn_timer = 0
	c.sharp_timer = 0
end)

Concord.component("scatter_away_from", function (c, e_target, distance, speed)
	assert(e_target.__isEntity)
	assert:type(distance, "number")
	assert:type(speed, "number")
	e_target:ensure("key")
	c.key = e_target:get("key").value
	c.distance = distance
	c.speed = speed
	c.is_overlap = false
	c.escape_target = nil
end)
