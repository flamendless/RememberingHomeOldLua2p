Concord.component("speed", function(c, vx, vy)
	assert:type_or_nil(vx, "number")
	assert:type_or_nil(vy, "number")
	c.vx = vx or 0
	c.vy = vy or 0
end)

Concord.component("speed_data", function(c, speed_data)
	assert:type_or_nil(speed_data, "table")

	for _, v in ipairs(speed_data) do
		assert:type(v.x, "number")
		assert:type(v.y, "number")
	end

	c.speed_data = speed_data
end)

Concord.component("hspeed", function(c, hspeed)
	assert:type(hspeed, "number")
	c.value = hspeed
end)
