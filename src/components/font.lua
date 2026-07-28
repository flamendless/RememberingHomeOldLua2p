local c_font = Concord.component("font", function(c, resource_id)
	assert:type(resource_id, "string")
	c.resource_id = resource_id
	c.value = Resources.data.fonts[resource_id]
end)

function c_font:serialize()
	return {
		resource_id = self.resource_id,
	}
end

function c_font:deserialize(data)
	self:__populate(data.resource_id)
end
