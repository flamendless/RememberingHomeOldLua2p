local c_attach_to = Concord.component("attach_to", function(c, e_target)
	if not e_target.__isEntity then
		error("Assertion failed: e_target.__isEntity")
	end
	e_target:ensure("key")
	c.key = e_target.key.value
end)

function c_attach_to:serialize()
	return { key = self.key }
end

function c_attach_to:deserialize(data)
	self.key = data.key
end

Concord.component("attach_to_offset", function(c, ox, oy)
	if type(ox) ~= "number" then
		error('Assertion failed: type(ox) == "number"')
	end
	if type(oy) ~= "number" then
		error('Assertion failed: type(oy) == "number"')
	end
	c.ox = ox
	c.oy = oy
end)

Concord.component("attach_to_spawn_point", function(c, x, y)
	if type(x) ~= "number" then
		error('Assertion failed: type(x) == "number"')
	end
	if type(y) ~= "number" then
		error('Assertion failed: type(y) == "number"')
	end
	c.x = x
	c.y = y
end)
