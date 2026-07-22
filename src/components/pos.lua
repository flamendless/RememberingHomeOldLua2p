--filled in systems/transform
Concord.component("pos_vec2")

Concord.component("pos", function(c, x, y, z)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	if z then
		assert(type(z) == "number", z)
	end
	c.x = x
	c.y = y
	c.z = z
	c.orig_x = x
	c.orig_y = y
	c.orig_z = z
end)

Concord.component("ref_pos_vec2", function(c, x, y)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	c.value = vec2(x, y)
end)

Concord.component("size", function(c, w, h)
	assert(type(w) == "number")
	assert(type(h) == "number")
	c.w = w
	c.h = h
end)

Concord.component("controller_origin", function(c)
	c.x, c.y = nil, nil
	c.vec2 = vec2()
end)
