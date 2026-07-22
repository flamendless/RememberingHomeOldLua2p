Concord.component("speed", function(c, vx, vy)
	if vx then
		assert(type(vx) == "number", vx)
	end
	if vy then
		assert(type(vy) == "number", vy)
	end
	c.vx = vx or 0
	c.vy = vy or 0
end)

Concord.component("speed_data", function(c, speed_data)
	if speed_data then
		assert(type(speed_data) == "table", speed_data)
	end

	for _, v in ipairs(speed_data) do
		assert(type(v.x) == "number", v.x)
		assert(type(v.y) == "number", v.y)
	end

	c.speed_data = speed_data
end)

Concord.component("hspeed", function(c, hspeed)
	assert(type(hspeed) == "number", hspeed)
	c.value = hspeed
end)
