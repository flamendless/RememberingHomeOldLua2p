

Concord.component("transform", function(c, rotation, sx, sy, ox, oy, kx, ky)
	assert:type_or_nil(rotation, "number")
	assert:type_or_nil(sx, "number")
	assert:type_or_nil(sy, "number")
	assert:type_or_nil(ox, "number")
	assert:type_or_nil(oy, "number")
	assert:type_or_nil(kx, "number")
	assert:type_or_nil(ky, "number")

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
	assert:type_or_nil(rotation, "number")
	assert:type_or_nil(sx, "number")
	assert:type_or_nil(sy, "number")
	assert:type_or_nil(ox, "number")
	assert:type_or_nil(oy, "number")
	assert:type_or_nil(kx, "number")
	assert:type_or_nil(ky, "number")

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
	assert:type(sx, "number")
	assert:type(sy, "number")
	assert:type(speed, "number")
	c.sx = sx
	c.sy = sy
	c.speed = speed
	c.dirx = 1
	c.diry = 1
end)

Concord.component("depth_zoom", function(c, zoom_factor)
	assert:type(zoom_factor, "number")
	c.value = zoom_factor
end)
