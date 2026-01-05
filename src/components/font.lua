local c_font = Concord.component("font", function(c, resource_id)
	if not (type(resource_id) == "string") then
		error('Assertion failed: type(resource_id) == "string"')
	end
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

local c_font_sdf = Concord.component("font_sdf", function(c, fnt, png)
	if not (type(fnt) == "string") then
		error('Assertion failed: type(fnt) == "string"')
	end
	if not (type(png) == "string") then
		error('Assertion failed: type(png) == "string"')
	end
	c.resource_fnt = fnt
	c.resource_png = png
	c.value = love.graphics.newFontMSDF(fnt, png)
end)

function c_font_sdf:serialize()
	return {
		resource_fnt = self.resource_fnt,
		resource_png = self.resource_png,
	}
end

function c_font_sdf:deserialize(data)
	self:__populate(data.resource_fnt, data.resource_png)
end

Concord.component("sdf", function(c, sx, sy)
	if sx then
		if not (type(sx) == "number") then
			error('Assertion failed: type(sx) == "number"')
		end
	end
	if sy then
		if not (type(sy) == "number") then
			error('Assertion failed: type(sy) == "number"')
		end
	end
	c.sx = sx or 1
	c.sy = sy or 1
end)
