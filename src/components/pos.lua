--filled in systems/transform
Concord.component("pos_vec2")

Concord.component("pos", function(c, x, y, z)
	if not (type(x) == "number") then
		error('Assertion failed: type(x) == "number"')
	end
	if not (type(y) == "number") then
		error('Assertion failed: type(y) == "number"')
	end
	if z then
		if not (type(z) == "number") then
			error('Assertion failed: type(z) == "number"')
		end
	end
	c.x = x
	c.y = y
	c.z = z
	c.orig_x = x
	c.orig_y = y
	c.orig_z = z
end)

Concord.component("ref_pos_vec2", function(c, x, y)
	if not (type(x) == "number") then
		error('Assertion failed: type(x) == "number"')
	end
	if not (type(y) == "number") then
		error('Assertion failed: type(y) == "number"')
	end
	c.value = vec2(x, y)
end)

Concord.component("size", function(c, w, h)
	if not (type(w) == "number") then
		error('Assertion failed: type(w) == "number"')
	end
	if not (type(h) == "number") then
		error('Assertion failed: type(h) == "number"')
	end
	c.w = w
	c.h = h
end)

Concord.component("controller_origin", function(c)
	c.x, c.y = nil, nil
	c.vec2 = vec2()
end)
