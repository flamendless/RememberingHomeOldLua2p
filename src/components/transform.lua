

Concord.component("transform", function(c, rotation, sx, sy, ox, oy, kx, ky)
	if rotation then
		assert(type(rotation) == "number", rotation)
	end
	if sx then
		assert(type(sx) == "number", sx)
	end
	if sy then
		assert(type(sy) == "number", sy)
	end
	if ox then
		assert(type(ox) == "number", ox)
	end
	if oy then
		assert(type(oy) == "number", oy)
	end
	if kx then
		assert(type(kx) == "number", kx)
	end
	if ky then
		assert(type(ky) == "number", ky)
	end

	c.rotation = rotation or 0
	c.sx = sx or 1
	c.sy = sy or 1
	c.ox = ox or 0
	c.oy = oy or 0
	c.kx = kx or 0
	c.ky = ky or 0
	c.orig_sx = c.sx
	c.orig_sy = c.sy
end)

Concord.component("quad_transform", function(c, rotation, sx, sy, ox, oy, kx, ky)
	if rotation then
		assert(type(rotation) == "number", rotation)
	end
	if sx then
		assert(type(sx) == "number", sx)
	end
	if sy then
		assert(type(sy) == "number", sy)
	end
	if ox then
		assert(type(ox) == "number", ox)
	end
	if oy then
		assert(type(oy) == "number", oy)
	end
	if kx then
		assert(type(kx) == "number", kx)
	end
	if ky then
		assert(type(ky) == "number", ky)
	end

	c.rotation = rotation or 0
	c.sx = sx or 1
	c.sy = sy or 1
	c.ox = ox or 0
	c.oy = oy or 0
	c.kx = kx or 0
	c.ky = ky or 0
	c.orig_sx = c.sx
	c.orig_sy = c.sy
end)

-- INFO: fake pulsing/animation via scale manipulation
Concord.component("fake_pulse", function(c, sx, sy, speed)
	assert(type(sx) == "number")
	assert(type(sy) == "number")
	assert(type(speed) == "number")
	c.sx = sx
	c.sy = sy
	c.speed = speed
	c.dirx = 1
	c.diry = 1
end)

Concord.component("depth_zoom", function(c, zoom_factor)
	assert(type(zoom_factor) == "number", zoom_factor)
	c.value = zoom_factor
end)
