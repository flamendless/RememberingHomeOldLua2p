local Generator = {}

function Generator.path_points_fireflies(x, y, n)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	assert(type(n) == "number", n)
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
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	assert(type(ex) == "number", ex)
	assert(type(ey) == "number", ey)
	assert(type(n) == "number", n)
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
