Concord.component("path", function(c, points, max, current_point)
	assert(type(points) == "table", points)
	if max then
		assert((type(max) == "number" and max > 0), max)
	end
	if current_point then
		assert(type(current_point) == "number", current_point)
	end

	for _, v in ipairs(points) do
		assert(type(v.x) == "number", v.x)
		assert(type(v.y) == "number", v.y)
	end

	c.points = points
	c.n_points = #points
	c.current_point = current_point or 1
	c.dir = love.math.random() < 0.5 and 1 or -1
	c.max = max or 1
end)

Concord.component("path_speed", function(c, speed)
	assert(type(speed) == "number", speed)
	c.value = speed
end)

Concord.component("apply_bezier_curve", function(c)
	c.dt = 0
	c.t = 0
end)

Concord.component("path_loop")
Concord.component("path_repeat")
Concord.component("path_move")
