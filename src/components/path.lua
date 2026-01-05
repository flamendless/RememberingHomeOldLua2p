Concord.component("path", function(c, points, max)
	if not (type(points) == "table") then
		error('Assertion failed: type(points) == "table"')
	end
	if max then
		if not (type(max) == "number" and max > 0) then
			error('Assertion failed: type(max) == "number" and max > 0')
		end
	end

	for _, v in ipairs(points) do
		if not (type(v.x) == "number") then
			error('Assertion failed: type(v.x) == "number"')
		end
		if not (type(v.y) == "number") then
			error('Assertion failed: type(v.y) == "number"')
		end
	end

	c.points = points
	c.n_points = #points
	c.current_point = 1
	c.max = max or 1
end)

Concord.component("path_speed", function(c, speed)
	if not (type(speed) == "number") then
		error('Assertion failed: type(speed) == "number"')
	end
	c.value = speed
end)

Concord.component("apply_bezier_curve", function(c)
	c.dt = 0
end)

Concord.component("path_loop")
Concord.component("path_repeat")
Concord.component("path_move")
