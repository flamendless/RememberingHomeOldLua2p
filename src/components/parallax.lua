--TODO: (Brandon) make parallax stop system signal?
Log.debug("TODO: (Brandon) make parallax stop system signal?")
Concord.component("parallax_stop")

Concord.component("parallax", function(c, vx, vy)
	assert:type(vx, "number")
	assert:type(vy, "number")
	c.vx = vx
	c.vy = vy
end)

Concord.component("parallax_multi_sprite", function(c, tag)
	assert:type(tag, "string")
	c.value = tag
end)

Concord.component("parallax_gap", function(c, gap)
	assert:type(gap, "number")
	c.value = gap
end)
