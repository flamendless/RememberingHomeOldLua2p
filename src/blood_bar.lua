local BloodBar = class({
	name = "BloodBar",
})

local white_pixel

function BloodBar.init()
	local data = love.image.newImageData(1, 1)
	data:setPixel(0, 0, 1, 1, 1, 1)
	white_pixel = love.graphics.newImage(data)
end

function BloodBar:new(opts)
	opts = opts or {}
	self.shader = love.graphics.newShader(Shaders.paths.blood_bar)
	if opts.enabled then
		self.enabled = opts.enabled
	else
		self.enabled = false
	end
	self.data = {
		time = 0,
		speed = opts.speed or 1,
		opacity = opts.opacity or 1.0,
		fade_width = opts.fade_width or 0.15,
		tint = opts.tint or 1.0,
		direction = opts.direction or {1, 0},
	}
end

function BloodBar:update(dt)
	if not self.enabled then return end
	self.data.time = self.data.time + dt * self.data.speed
end

function BloodBar:draw(x, y, w, h)
	if not self.enabled then return end
	self.shader:send("time", self.data.time)
	self.shader:send("opacity", self.data.opacity)
	self.shader:send("fade_width", self.data.fade_width)
	self.shader:send("tint", self.data.tint)
	self.shader:send("direction", self.data.direction)

	local prev_shader = love.graphics.getShader()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setShader(self.shader)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(white_pixel, x, y, 0, w, h)
	love.graphics.setShader(prev_shader)
	love.graphics.setColor(r, g, b, a)
end

return BloodBar
