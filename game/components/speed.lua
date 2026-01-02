Concord.component("speed", function(c, vel)
	SASSERT(vel, function() return vel:type() == "vec2" end)
	c.value = vel or vec2()
end)

Concord.component("speed_data", function(c, speed_data)
	SASSERT(speed_data, type(speed_data) == "table")
	if DEV then
		for k, v in pairs(speed_data) do
			ASSERT(v:type() == "vec2", k)
		end
	end
	c.speed_data = speed_data
end)

Concord.component("hspeed", function(c, hspeed)
	ASSERT(type(hspeed) == "number")
	c.value = hspeed
end)
