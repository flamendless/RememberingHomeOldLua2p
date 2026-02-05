local Dissolve = class({
	name = "Dissolve",
})

local function smootherstep(v)
	return v * v * v * (v * (v * 6 - 15) + 10)
end

function Dissolve:new(texture, duration)
	if not (texture:type() == "Image") then
		error('Assertion failed: texture:type() == "Image"')
	end
	if type(duration) ~= "number" then
		error('Assertion failed: type(duration) == "number"')
	end
	self.shader_code = love.graphics.newShader(Shaders.paths.dissolve)
	self.shader_code:send("u_tex_noise", texture)
	self.flag_process = false
	self.duration = duration
	self.time = 0
	self.dir = 1
	self.kind = -1
end

function Dissolve:set_kind(kind)
	if type(kind) ~= "number" then
		error('Assertion failed: type(kind) == "number"')
	end
	self.kind = kind
end

function Dissolve:update(dt)
	if not self.shader_code or not self.flag_process then
		return
	end

	self.time = self.time + dt * self.dir
	local n = self.kind + smootherstep(math.max(0, math.min(self.time / self.duration, 1)))
	self.shader_code:send("u_time", math.abs(n))

	if self.time > self.duration then
		if self.on_complete then
			self.on_complete()
			self.on_complete = nil
		end

		self.flag_process = false
	end
end

function Dissolve:draw(fn)
	if type(fn) ~= "function" then
		error('Assertion failed: type(fn) == "function"')
	end
	if self.flag_process then
		love.graphics.setShader(self.shader_code)
		fn()
		love.graphics.setShader()
	else
		fn()
	end
end

function Dissolve:draw_emit(world, ev_name)
	if not world.__isWorld then
		error("Assertion failed: world.__isWorld")
	end
	if not (type(ev_name) == "string" and ev_name ~= "") then
		error('Assertion failed: type(ev_name) == "string" and ev_name ~= ""')
	end
	if self.flag_process then
		love.graphics.setShader(self.shader_code)
		world:emit(ev_name)
		love.graphics.setShader()
	else
		world:emit(ev_name)
	end
end

return Dissolve
