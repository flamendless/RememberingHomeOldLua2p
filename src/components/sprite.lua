

Concord.component("bg")
Concord.component("array_image")

local c_sprite = Concord.component("sprite", function(c, resource_id, container)
	assert(type(resource_id) == "string", resource_id)
	if container then
		assert(type(container) == "string", container)
	end
	c.resource_id = resource_id
	c.container = container or "images"
	c.image = Resources.data[c.container][resource_id]
	c.iw, c.ih = c.image:getDimensions()
end)

function c_sprite:serialize()
	return {
		resource_id = self.resource_id,
		container = self.container,
	}
end

function c_sprite:deserialize(data)
	self:__populate(data.resource_id, data.container)
end

--TODO: (Brandon) remove with fog?
local c_noise_tex = Concord.component("noise_texture", function(c, w, h)
	assert(type(w) == "number", w)
	assert(type(h) == "number", h)
	c.w = w
	c.h = h
	c.texture = love.graphics.newImage(Image.generate_noise(w, h))
	c.texture:setWrap("repeat", "repeat")
	c.texture:setFilter("linear", "linear")
end)

function c_noise_tex:serialize()
	return {
		w = self.w,
		h = self.h,
	}
end

function c_noise_tex:deserialize(data)
	self:__populate(data.w, data.h)
end
