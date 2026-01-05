Concord.component("bounding_box", function(c, x, y, w, h)
	if not (type(x) == "number") then
		error('Assertion failed: type(x) == "number"')
	end
	if not (type(y) == "number") then
		error('Assertion failed: type(y) == "number"')
	end
	if not (type(w) == "number") then
		error('Assertion failed: type(w) == "number"')
	end
	if not (type(h) == "number") then
		error('Assertion failed: type(h) == "number"')
	end
	c.x = x
	c.y = y
	c.w = w
	c.h = h
	c.screen_pos = {
		x = x,
		y = y,
	}
end)
