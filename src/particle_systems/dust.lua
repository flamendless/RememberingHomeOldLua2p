local lg = love.graphics

local HP = {
	emission_rate = 24,
	emitter_lifetime = 1.5,
	emit_at_start = 36,
	particle_lifetime_min = 1.4,
	particle_lifetime_max = 2.8,
	speed_min = 10,
	speed_max = 32,
	linear_accel_min_x = -6,
	linear_accel_min_y = -6,
	linear_accel_max_x = 6,
	linear_accel_max_y = 10,
	linear_damping_min = 0.4,
	linear_damping_max = 0.85,
	radial_accel_min = -4,
	radial_accel_max = 4,
	emission_height = 2,
}

local POOL_SIZE = 32
local TEXTURE_SIZE = 4
local BUFFER = 80

local function dust_colors_from_base(color)
	local r, g, b = color[1], color[2], color[3]
	local a = color[4] or 1
	return
		r, g, b, a * 0.9,
		r, g, b, a * 0.55,
		r, g, b, a * 0.2,
		r, g, b, 0
end

local function generate_dust_texture(size)
	assert:type(size, "number")
	Log.trace("generating dust texture", size, "x", size)
	local data = love.image.newImageData(size, size)
	local cx = (size - 1) * 0.5
	local cy = (size - 1) * 0.5
	data:mapPixel(function(x, y)
		local dx = math.abs(x - cx)
		local dy = math.abs(y - cy)
		local edge = math.max(dx, dy) / math.max(cx, cy, 1)
		local alpha = 1 - math.min(1, edge * edge)
		return 1, 1, 1, alpha
	end)

	local image = lg.newImage(data)
	image:setFilter("nearest", "nearest")
	return image
end

local PSDust = class({
	name = "PSDust",
})

function PSDust:new(image)
	assert(image:type() == "Image", image)
	self.image = image
	self.system = nil
	self.blend_mode = "alpha"
	self.x = 0
	self.y = 0
end

function PSDust:create_system()
	local ps = lg.newParticleSystem(self.image, BUFFER)

	ps:setInsertMode("top")
	ps:setLinearAcceleration(
		HP.linear_accel_min_x,
		HP.linear_accel_min_y,
		HP.linear_accel_max_x,
		HP.linear_accel_max_y
	)
	ps:setLinearDamping(HP.linear_damping_min, HP.linear_damping_max)
	ps:setOffset(TEXTURE_SIZE / 2, TEXTURE_SIZE / 2)
	ps:setRadialAcceleration(HP.radial_accel_min, HP.radial_accel_max)
	ps:setRelativeRotation(false)
	ps:setRotation(0, 0)
	ps:setSpin(0, 0)
	ps:setSpinVariation(0)
	ps:setSpread(0.03)
	ps:setTangentialAcceleration(0, 0)

	return ps
end

function PSDust:configure(config)
	assert:type(config, "table")
	self.system = self:create_system()
	local ps = self.system
	local strength = config.strength or 1

	self.x = config.x + config.w / 2
	self.y = config.y

	ps:setColors(dust_colors_from_base(config.color))
	ps:setDirection(config.direction)
	ps:setEmissionArea("ellipse", math.max(config.w / 2, 1), HP.emission_height, 0, false)
	ps:setEmissionRate(HP.emission_rate * strength)
	ps:setEmitterLifetime(config.emitter_lifetime or HP.emitter_lifetime)
	ps:setParticleLifetime(
		config.particle_lifetime_min or HP.particle_lifetime_min,
		config.particle_lifetime_max or HP.particle_lifetime_max
	)
	local sz = config.size
	ps:setSizes(sz, sz * 0.7, sz * 0.35, 0)
	ps:setSizeVariation(config.size_variation)
	ps:setSpeed(HP.speed_min * strength, HP.speed_max * strength)

	local emit_at_start = config.emit_at_start or HP.emit_at_start
	self.emit_count = math.max(1, math.floor(emit_at_start * strength))
end

function PSDust:trigger()
	self.system:reset()
	self.system:emit(self.emit_count)
end

function PSDust:update(dt)
	assert:type(dt, "number")
	if not self.system or self.system:getCount() == 0 then
		return
	end

	self.system:update(dt)
end

function PSDust:is_alive()
	return self.system and (self.system:getCount() > 0 or self.system:isActive())
end

function PSDust:draw(x, y)
	assert:type_or_nil(x, "number")
	assert:type_or_nil(y, "number")
	if not self:is_alive() then
		return
	end

	lg.setBlendMode(self.blend_mode)
	lg.draw(self.system, x or self.x, y or self.y)
end

local DustPool = class({
	name = "DustPool",
})

function DustPool:new()
	self.image = generate_dust_texture(TEXTURE_SIZE)
	self.pool = {}
	for _ = 1, POOL_SIZE do
		table.insert(self.pool, PSDust(self.image))
	end
end

function DustPool:acquire()
	for _, burst in ipairs(self.pool) do
		if not burst:is_alive() then
			return burst
		end
	end
	return self.pool[love.math.random(1, #self.pool)]
end

function DustPool:trigger(config)
	assert:type(config, "table")
	local burst = self:acquire()
	burst:configure(config)
	burst:trigger()
	return burst
end

function DustPool:update(dt)
	assert:type(dt, "number")
	for _, burst in ipairs(self.pool) do
		burst:update(dt)
	end
end

function DustPool:draw()
	lg.setColor(1, 1, 1, 1)
	for _, burst in ipairs(self.pool) do
		burst:draw()
	end
	lg.setBlendMode("alpha")
end

return DustPool
