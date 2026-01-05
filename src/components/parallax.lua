--TODO make parallax stop system signal?
Concord.component("parallax_stop")

Concord.component("parallax", function(c, vx, vy)
	if not (type(vx) == "number") then
		error('Assertion failed: type(vx) == "number"')
	end
	if not (type(vy) == "number") then
		error('Assertion failed: type(vy) == "number"')
	end
	c.vx = vx
	c.vy = vy
end)

Concord.component("parallax_multi_sprite", function(c, tag)
	if not (type(tag) == "string") then
		error('Assertion failed: type(tag) == "string"')
	end
	c.value = tag
end)

Concord.component("parallax_gap", function(c, gap)
	if not (type(gap) == "number") then
		error('Assertion failed: type(gap) == "number"')
	end
	c.value = gap
end)
