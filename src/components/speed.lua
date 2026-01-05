Concord.component("speed", function(c, vx, vy)
	if vx then
		if not (type(vx) == "number") then
			error('Assertion failed: type(vx) == "number"')
		end
	end
	if vy then
		if not (type(vy) == "number") then
			error('Assertion failed: type(vy) == "number"')
		end
	end
	c.vx = vx or 0
	c.vy = vy or 0
end)

Concord.component("speed_data", function(c, speed_data)
	if speed_data then
		if not (type(speed_data) == "table") then
			error('Assertion failed: type(speed_data) == "table"')
		end
	end

	for i, v in ipairs(speed_data) do
		if not (type(v.x) == "number") then
			error('Assertion failed: type(v.x) == "number"')
		end
		if not (type(v.y) == "number") then
			error('Assertion failed: type(v.y) == "number"')
		end
	end

	c.speed_data = speed_data
end)

Concord.component("hspeed", function(c, hspeed)
	if not (type(hspeed) == "number") then
		error('Assertion failed: type(hspeed) == "number"')
	end
	c.value = hspeed
end)
