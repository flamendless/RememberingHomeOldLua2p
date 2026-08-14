local aux = { 0, 0, 0, 0 }

local function send_uniforms(self)
	local data = self.data
	self.shader:send("time", data.time)
	self.shader:send("opacity", data.opacity)
	self.shader:send("overlay_strength", data.overlay_strength)
end

local function draw(self, img, ...)
	local quad = (...)
	if type(quad) == "userdata" then
		local sx, sy = quad:getTextureDimensions()
		aux[1], aux[2], aux[3], aux[4] = quad:getViewport()
		aux[1] = aux[1] / sx
		aux[2] = aux[2] / sy
		aux[3] = aux[3] / sx
		aux[4] = aux[4] / sy
	else
		aux[1], aux[2], aux[3], aux[4] = 0, 0, 1, 1
	end
	self.shader:send("quad", aux)

	send_uniforms(self)
	love.graphics.setShader(self.shader)
	love.graphics.draw(img, ...)
	love.graphics.setShader()
end

local BloodHighlight = {}

function BloodHighlight.new()
	return {
		shader = love.graphics.newShader(Shaders.paths.interactive_blood),
		draw = draw,
		data = {
			time = 0,
			opacity = 1,
			overlay_strength = 0.72,
		},
	}
end

return BloodHighlight
