local Generator = {}

function Generator.path_points_fireflies(x, y, n)
	assert:type(x, "number")
	assert:type(y, "number")
	assert:type(n, "number")
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

function Generator.path_points_ants(x, y, ex, ey, n, max_sway)
	assert:type(x, "number")
	assert:type(y, "number")
	assert:type(ex, "number")
	assert:type(ey, "number")
	assert:type(n, "number")
	assert:type_or_nil(max_sway, "number")

	max_sway = max_sway or 2
	local points = {}
	local ax, ay = ex - x, ey - y
	local len = math.max(math.sqrt(ax * ax + ay * ay), 1)
	local nx, ny = -ay / len, ax / len
	local along_jitter = math.max(1, math.floor(max_sway * 0.15))

	for i = 0, n - 1 do
		local t = (n <= 1) and 0 or (i / (n - 1))
		local px = mathx.lerp(x, ex, t)
		local py = mathx.lerp(y, ey, t)
		local sway = love.math.random(-max_sway, max_sway)
		px = px + nx * sway + love.math.random(-along_jitter, along_jitter)
		py = py + ny * sway + love.math.random(-along_jitter, along_jitter)
		table.insert(points, { x = px, y = py })
	end
	Log.info("Generated # of points for ants", #points)
	return points
end

return Generator
