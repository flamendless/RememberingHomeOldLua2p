local MotionBlur = class({
	name = "MotionBlur",
})

function MotionBlur:new(canvas, config)
	if not (canvas:type() == "CustomCanvas") then
		error('Assertion failed: canvas:type() == "CustomCanvas"')
	end
	if config then
		if not (type(config) == "table") then
			error('Assertion failed: type(config) == "table"')
		end
	end
	self.shader_code = love.graphics.newShader(Shaders.paths.motion_blur)
	self.shader_code:send("u_strength", 0.1)
	self.flag_process = false
	self.canvas = canvas
	self.previous = {}
end

function MotionBlur:store_previous(x, y, angle)
	self.previous.target = vec2(x, y)
	self.previous.angle = angle
end

function MotionBlur:set_angle(angle)
	if not (type(angle) == "number") then
		error('Assertion failed: type(angle) == "number"')
	end
	self.shader_code:send("u_angle", angle)
end

function MotionBlur:set_strength(strength)
	if not (type(strength) == "number") then
		error('Assertion failed: type(strength) == "number"')
	end
	self.shader_code:send("u_strength", strength)
end

function MotionBlur:post_process_draw()
	if not self.flag_process then
		return
	end
	love.graphics.setShader(self.shader_code)
	self.canvas:render()
	love.graphics.setShader()
end

return MotionBlur
