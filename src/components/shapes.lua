Concord.component("textured_line")

Concord.component("draw_mode", function(c, draw_mode)
	assert(type(draw_mode) == "string")
	assert(Enums.mode[draw_mode])
	c.value = draw_mode
end)

Concord.component("point", function(c, size)
	if not (type(size) == "number" and size >= 1) then
		error('Assertion failed: type(size) == "number" and size >= 1')
	end
	c.value = size
end)

Concord.component("circle", function(c, radius, segments, start_angle, end_angle)
	if not (type(radius) == "number") then
		error('Assertion failed: type(radius) == "number"')
	end
	if segments then
		if not (type(segments) == "number") then
			error('Assertion failed: type(segments) == "number"')
		end
	end
	if start_angle then
		if not (type(start_angle) == "number") then
			error('Assertion failed: type(start_angle) == "number"')
		end
	end
	if end_angle then
		if not (type(end_angle) == "number") then
			error('Assertion failed: type(end_angle) == "number"')
		end
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
	if not (type(w) == "number") then
		error('Assertion failed: type(w) == "number"')
	end
	if not (type(h) == "number") then
		error('Assertion failed: type(h) == "number"')
	end
	c.w = w
	c.h = h
	c.half_w = w/2
	c.half_h = h/2
end)

Concord.component("rect_border", function(c, rx, ry)
	if not (type(rx) == "number") then
		error('Assertion failed: type(rx) == "number"')
	end
	if not (type(ry) == "number") then
		error('Assertion failed: type(ry) == "number"')
	end
	c.rx = rx
	c.ry = ry
end)

Concord.component("line_width", function(c, line_width)
	if not (type(line_width) == "number") then
		error('Assertion failed: type(line_width) == "number"')
	end
	c.value = line_width
end)

Concord.component("arc_type", function(c, arc_type)
	c.value = arc_type
end)
