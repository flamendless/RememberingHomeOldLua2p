Concord.component("target_text", function(c, text)
	if type(text) ~= "string" then
		error('Assertion failed: type(text) == "string"')
	end
	c.value = text
end)

Concord.component("text", function(c, text)
	if type(text) ~= "string" then
		error('Assertion failed: type(text) == "string"')
	end
	c.value = text
end)

Concord.component("text_t", function(c, t)
	if type(t) ~= "table" then
		error("got " .. type(t))
	end
	c.value = t
	c.current_index = 1
	c.max_n = #t
end)

Concord.component("textf", function(c, limit, align)
	if type(limit) ~= "number" then
		error('Assertion failed: type(limit) == "number"')
	end
	if type(align) ~= "string" then
		error('Assertion failed: type(align) == "string"')
	end
	c.limit = limit
	c.align = align
end)

local c_static_text = Concord.component("static_text", function(c, text)
	if type(text) ~= "string" then
		error('Assertion failed: type(text) == "string"')
	end
	c.value = text
	c.obj = nil
end)

function c_static_text:serialize()
	return {
		value = self.value,
	}
end

function c_static_text:deserialize(data)
	self:__populate(data.value)
end
