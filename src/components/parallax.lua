--TODO: (Brandon) make parallax stop system signal?
Concord.component("parallax_stop")

Concord.component("parallax", function(c, vx, vy)
	if type(vx) ~= "number" then
		error('Assertion failed: type(vx) == "number"')
	end
	if type(vy) ~= "number" then
		error('Assertion failed: type(vy) == "number"')
	end
	c.vx = vx
	c.vy = vy
end)

Concord.component("parallax_multi_sprite", function(c, tag)
	if type(tag) ~= "string" then
		error('Assertion failed: type(tag) == "string"')
	end
	c.value = tag
end)

Concord.component("parallax_gap", function(c, gap)
	if type(gap) ~= "number" then
		error('Assertion failed: type(gap) == "number"')
	end
	c.value = gap
end)
