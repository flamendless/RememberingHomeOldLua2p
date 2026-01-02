local Generator = {}

function Generator.generate_noise_image(w, h)
	ASSERT(type(w) == "number")
	ASSERT(type(h) == "number")
	local data = love.image.newImageData(w, h)
	data:mapPixel(function(x, y)
		local n = love.math.noise(x, y)
		return n, n, n, 1
	end)
	return data
end

function Generator.path_points_fireflies(x, y, n)
	ASSERT(type(x) == "number")
	ASSERT(type(y) == "number")
	ASSERT(type(n) == "number")
	local offset = 8
	local points = {vec2(x, y)}
	local prev_pos = vec2(x, y)

	for _ = 1, n - 1 do
		local px = love.math.random(prev_pos.x - offset, prev_pos.x + offset)
		local py = love.math.random(prev_pos.y - offset, prev_pos.y + offset)
		local p = vec2(px, py)
		prev_pos = p:copy()
		table.insert(points, p)
	end
	return points
end

function Generator.path_points_ants(start_pos, end_pos, n)
	ASSERT(start_pos:type() == "vec2")
	ASSERT(end_pos:type() == "vec2")
	ASSERT(type(n) == "number")
	local points = {}
	local dir = vec2(1, (start_pos.y <= end_pos.y) and -1 or 1)
	local offset = 2

	for i = 0, n - 1 do
		local t = i/n
		local ox = love.math.random(-offset, offset)
		local oy = love.math.random(-offset, offset)
		local delta_pos = start_pos:copy():lerp_inplace(end_pos, t)
		delta_pos:sadd_inplace(ox, oy):vector_mul_inplace(dir)
		dir:smul_inplace(-1)
		table.insert(points, delta_pos)
	end
	return points
end

function Generator.path_points_flies(pos)
	ASSERT(pos:type() == "vec2")
	local min = vec2(8, 16)
	local max = vec2(6, 12)

	--[[
	  b  c  d
	a    o    e
	  h  g  f
	--]]

	local hx = love.math.random(min.x, max.x)
	local hx_h = hx * 0.5
	local hy = love.math.random(min.y, max.y)
	local hy_h = hy * 0.75

	local o = pos:copy()
	local vecs = {
		o:sadd(-hx, 0), --a
		o:sadd(-hx_h, -hy_h), --b
		o:sadd(0, -hy), --c
		o:sadd(hx_h, -hy_h), --d
		o:sadd(hx, 0), --e

		o:sadd(hx_h, hy_h), --f
		o:sadd(0, hy), --g
		o:sadd(-hx_h, hy_h), --h
	}

	local points = {}
	local r = love.math.random(math.pi/6, math.pi/4)
	for _, v in ipairs(vecs) do
		v:rotate_around_inplace(r, o)
		table.insert(points, vec2(v.x, v.y))
	end
	return points
end

return Generator
