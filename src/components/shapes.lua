Concord.component("textured_line")

Concord.component("draw_mode", function(c, draw_mode)
	assert(type(draw_mode) == "string")
	assert(Enums.mode[draw_mode])
	c.value = draw_mode
end)

Concord.component("point", function(c, size)
	assert(type(size) == "number" and size >= 1, size)
	c.value = size
end)

Concord.component("circle", function(c, radius, segments, start_angle, end_angle)
	assert(type(radius) == "number", radius)
	if segments then
		assert(type(segments) == "number", segments)
	end
	if start_angle then
		assert(type(start_angle) == "number", start_angle)
	end
	if end_angle then
		assert(type(end_angle) == "number", end_angle)
	end
	c.radius = radius
	c.segments = segments or radius

	if start_angle and end_angle then
		c.start_angle = start_angle or -1.5707963267949
		c.end_angle = end_angle or 6.2831853071796
		c.is_arc = true
	end
end)

Concord.component("rect", function(c, w, h)
	assert(type(w) == "number", w)
	assert(type(h) == "number", h)
	c.w = w
	c.h = h
	c.half_w = w/2
	c.half_h = h/2
end)

Concord.component("rect_border", function(c, rx, ry)
	assert(type(rx) == "number", rx)
	assert(type(ry) == "number", ry)
	c.rx = rx
	c.ry = ry
end)

Concord.component("line_width", function(c, line_width)
	assert(type(line_width) == "number", line_width)
	c.value = line_width
end)

Concord.component("arc_type", function(c, arc_type)
	c.value = arc_type
end)
