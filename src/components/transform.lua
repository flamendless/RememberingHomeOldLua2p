

Concord.component("transform", function(c, rotation, sx, sy, ox, oy, kx, ky)
	if rotation then
		if type(rotation) ~= "number" then
			error('Assertion failed: type(rotation) == "number"')
		end
	end
	if sx then
		if type(sx) ~= "number" then
			error('Assertion failed: type(sx) == "number"')
		end
	end
	if sy then
		if type(sy) ~= "number" then
			error('Assertion failed: type(sy) == "number"')
		end
	end
	if ox then
		if type(ox) ~= "number" then
			error('Assertion failed: type(ox) == "number"')
		end
	end
	if oy then
		if type(oy) ~= "number" then
			error('Assertion failed: type(oy) == "number"')
		end
	end
	if kx then
		if type(kx) ~= "number" then
			error('Assertion failed: type(kx) == "number"')
		end
	end
	if ky then
		if type(ky) ~= "number" then
			error('Assertion failed: type(ky) == "number"')
		end
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
		if type(rotation) ~= "number" then
			error('Assertion failed: type(rotation) == "number"')
		end
	end
	if sx then
		if type(sx) ~= "number" then
			error('Assertion failed: type(sx) == "number"')
		end
	end
	if sy then
		if type(sy) ~= "number" then
			error('Assertion failed: type(sy) == "number"')
		end
	end
	if ox then
		if type(ox) ~= "number" then
			error('Assertion failed: type(ox) == "number"')
		end
	end
	if oy then
		if type(oy) ~= "number" then
			error('Assertion failed: type(oy) == "number"')
		end
	end
	if kx then
		if type(kx) ~= "number" then
			error('Assertion failed: type(kx) == "number"')
		end
	end
	if ky then
		if type(ky) ~= "number" then
			error('Assertion failed: type(ky) == "number"')
		end
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

Concord.component("depth_zoom", function(c, zoom_factor)
	if type(zoom_factor) ~= "number" then
		error('Assertion failed: type(zoom_factor) == "number"')
	end
	c.value = zoom_factor
end)
