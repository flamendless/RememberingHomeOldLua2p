local Concord = require("modules.concord.concord")

local c_anchor = Concord.component("anchor", function(c, entity, ax, ay, padding_x, padding_y)
	if not entity.__isEntity then
		error("Assertion failed: entity.__isEntity")
	end
	if not (type(ax) == "string") then
		error('Assertion failed: type(ax) == "string"')
	end
	if not (type(ay) == "string") then
		error('Assertion failed: type(ay) == "string"')
	end
	if padding_x then
		if not (type(padding_x) == "number") then
			error('Assertion failed: type(padding_x) == "number"')
		end
	end
	if padding_y then
		if not (type(padding_y) == "number") then
			error('Assertion failed: type(padding_y) == "number"')
		end
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
