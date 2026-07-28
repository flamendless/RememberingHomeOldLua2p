Concord.component("path", function(c, points, max, current_point)
	assert:type(points, "table")
	if max then
		assert((type(max) == "number" and max > 0), max)
	end
	assert:type_or_nil(current_point, "number")

	for _, v in ipairs(points) do
		assert:type(v.x, "number")
		assert:type(v.y, "number")
	end

	c.points = points
	c.n_points = #points
	c.current_point = current_point or 1
	c.dir = love.math.random() < 0.5 and 1 or -1
	c.max = max or 1
end)

Concord.component("path_speed", function(c, speed)
	assert:type(speed, "number")
	c.value = speed
end)

Concord.component("apply_bezier_curve", function(c)
	c.dt = 0
	c.t = 0
end)

Concord.component("path_loop")
Concord.component("path_repeat")
Concord.component("path_move")
