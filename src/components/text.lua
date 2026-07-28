Concord.component("target_text", function(c, text)
	assert:type(text, "string")
	c.value = text
end)

Concord.component("text", function(c, text)
	assert:type(text, "string")
	c.value = text
end)

Concord.component("text_t", function(c, t)
	assert:type(t, "table")
	c.value = t
	c.current_index = 1
	c.max_n = #t
end)

Concord.component("textf", function(c, limit, align)
	assert:type(limit, "number")
	assert:type(align, "string")
	c.limit = limit
	c.align = align
end)

local c_static_text = Concord.component("static_text", function(c, text)
	assert:type(text, "string")
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
