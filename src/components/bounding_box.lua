Concord.component("bounding_box", function(c, x, y, w, h)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	assert(type(w) == "number", w)
	assert(type(h) == "number", h)
	c.x = x
	c.y = y
	c.w = w
	c.h = h
	c.screen_pos = {
		x = x,
		y = y,
	}
end)
