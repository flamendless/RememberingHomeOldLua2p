local Generator = {}

function Generator.path_points_fireflies(x, y, n)
	if type(x) ~= "number" then
		error('Assertion failed: type(x) == "number"')
	end
	if type(y) ~= "number" then
		error('Assertion failed: type(y) == "number"')
	end
	if type(n) ~= "number" then
		error('Assertion failed: type(n) == "number"')
	end
	local offset = 8
	local points = { x = x, y = y }
	local prev_x = x
	local prev_y = y

	for _ = 1, n - 1 do
		local px = love.math.random(prev_x - offset, prev_x + offset)
		local py = love.math.random(prev_y - offset, prev_y + offset)
		local p = { x = px, y = py }
		prev_x = px
		prev_y = py
		table.insert(points, p)
	end
	Log.info("Generated # of points for fireflies", #points)
	return points
end

function Generator.path_points_ants(x, y, ex, ey, n)
	if type(x) ~= "number" then
		error('Assertion failed: type(x) == "number"')
	end
	if type(y) ~= "number" then
		error('Assertion failed: type(y) == "number"')
	end
	if type(ex) ~= "number" then
		error('Assertion failed: type(ex) == "number"')
	end
	if type(ey) ~= "number" then
		error('Assertion failed: type(ey) == "number"')
	end
	if type(n) ~= "number" then
		error('Assertion failed: type(n) == "number"')
	end
	local points = {}
	local dx = 1
	local dy = (y <= ey) and -1 or 1
	local offset = 2

	for i = 0, n - 1 do
		local t = i / n
		local ox = love.math.random(-offset, offset)
		local oy = love.math.random(-offset, offset)
		local px = mathx.lerp(x, ex, t)
		local py = mathx.lerp(y, ey, t)

		px = px + ox * dx
		py = py + oy * dy
		dx = dx * -1
		dy = dy * -1
		table.insert(points, { x = px, y = py })
	end
	Log.info("Generated # of points for ants", #points)
	return points
end

return Generator
