local c_attach_to = Concord.component("attach_to", function(c, e_target)
	assert(e_target.__isEntity, e_target)
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
	assert(type(ox) == "number", ox)
	assert(type(oy) == "number", oy)
	c.ox = ox
	c.oy = oy
end)

Concord.component("attach_to_spawn_point", function(c, x, y)
	assert(type(x) == "number", x)
	assert(type(y) == "number", y)
	c.x = x
	c.y = y
end)
