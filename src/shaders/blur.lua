local Blur = class({
	name = Enums.shaders.blur,
})

function Blur:new(is_active)
	assert:type_or_nil(is_active, "boolean")
	self.is_active = not not is_active --default is false
	self.shader = love.graphics.newShader(Shaders.paths.blur)
end

return Blur
