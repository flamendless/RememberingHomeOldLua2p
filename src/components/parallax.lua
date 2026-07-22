--TODO: (Brandon) make parallax stop system signal?
Concord.component("parallax_stop")

Concord.component("parallax", function(c, vx, vy)
	assert(type(vx) == "number", vx)
	assert(type(vy) == "number", vy)
	c.vx = vx
	c.vy = vy
end)

Concord.component("parallax_multi_sprite", function(c, tag)
	assert(type(tag) == "string", tag)
	c.value = tag
end)

Concord.component("parallax_gap", function(c, gap)
	assert(type(gap) == "number", gap)
	c.value = gap
end)
