local c_anchor = Concord.component("anchor", function(
	c,
	entity,
	ax,
	ay,
	padding_x,
	padding_y
)
	assert(entity.__isEntity, entity)
	assert(type(ax) == "string", ax)
	assert(type(ay) == "string", ay)
	if padding_x then
		assert(type(padding_x) == "number", padding_x)
	end
	if padding_y then
		assert(type(padding_y) == "number", padding_y)
	end

	entity:ensure("key")
	c.key = entity.key.value
	c.anchor_x = ax
	c.anchor_y = ay
	c.padding_x = padding_x
	c.padding_y = padding_y
end)

function c_anchor:serialize()
	return {
		key = self.key,
		anchor_x = self.anchor_x,
		anchor_y = self.anchor_y,
		padding_x = self.padding_x,
		padding_y = self.padding_y,
	}
end

function c_anchor:deserialize(data)
	self.key = data.key
	self.anchor_x = data.anchor_x
	self.anchor_y = data.anchor_y
	self.padding_x = data.padding_x
	self.padding_y = data.padding_y
end
