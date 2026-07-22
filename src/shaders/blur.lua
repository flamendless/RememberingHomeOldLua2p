local Blur = class({
	name = Enums.shaders.blur,
})

function Blur:new(is_active)
	if is_active then
		assert(type(is_active) == "boolean", is_active)
	end
	self.is_active = not not is_active --default is false
	self.shader = love.graphics.newShader(Shaders.paths.blur)
end

return Blur
