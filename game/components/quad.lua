Concord.component("grouped", function(c, id)
	ASSERT(type(id) == "string")
	c.value = id
end)

Concord.component("atlas", function(c, frame)
	ASSERT(type(frame) == "table")
	c.value = frame
end)

local c_quad = Concord.component("quad", function(c, quad, info)
	ASSERT(quad:type() == "Quad")
	SASSERT(info, type(info) == "table")
	c.quad = quad

	if info then
		c.info = info
	else
		local x, y, w, h = quad:getViewport()
		local sw, sh = quad:getTextureDimensions()
		c.info = {x = x, y = y, w = w, h = h, sw = sw, sh = sh}
	end
end)

function c_quad:serialize()
	local x, y, w, h = self.quad:getViewport()
	local sw, sh = self.quad:getTextureDimensions( )
	return {
		data = {x, y, w, h, sw, sh},
		info = self.info
	}
end

function c_quad:deserialize(data)
	local quad = love.graphics.newQuad(unpack(data.data))
	self:__populate(quad, data.info)
end
