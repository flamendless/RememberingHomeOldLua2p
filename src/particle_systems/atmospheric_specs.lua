local lg = love.graphics

local TEXTURE_SIZE = 4
local BUFFER = 256

local function colors_from_base(color)
	local r, g, b = color[1], color[2], color[3]
	local a = color[4] or 1
	return
		r, g, b, 0,
		r, g, b, a * 0.08,
		r, g, b, a * 0.18,
		r, g, b, a * 0.1,
		r, g, b, 0
end

local function generate_texture(size)
	assert:type(size, "number")
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

local function resolve_range(range, fallback)
	if type(range) == "table" then
		return range.min or fallback.min, range.max or fallback.max
	end
	return fallback.min, fallback.max
end

local shared_image = generate_texture(TEXTURE_SIZE)

local PSAtmosphericSpecs = class({
	name = "PSAtmosphericSpecs",
})

function PSAtmosphericSpecs:new(config)
	assert:type(config, "table")
	local defs = Data.AtmosphericSpecs.defaults
	self.blend_mode = config.blend_mode or defs.blend_mode
	self.x = 0
	self.y = 0
	self:configure(config)
end

function PSAtmosphericSpecs:configure(config)
	local defs = Data.AtmosphericSpecs.defaults
	local zone = config
	local speed = zone.speed or config.speed or defs.speed
	local lifetime = zone.lifetime or config.lifetime or defs.lifetime
	local drift_x = zone.drift_x or config.drift_x or defs.drift_x
	local gravity = zone.gravity or config.gravity or defs.gravity

	local direction_offset = zone.direction_offset or config.direction_offset or defs.direction_offset
	local direction = zone.direction or (math.pi / 2 + direction_offset)
	local spread = zone.spread or config.spread or defs.spread
	local emission_rate = zone.emission_rate or config.emission_rate or defs.emission_rate
	local emission_height = zone.emission_height or config.emission_height or defs.emission_height
	local speed_min, speed_max = resolve_range(speed, defs.speed)
	local lifetime_min, lifetime_max = resolve_range(lifetime, defs.lifetime)
	local size_min = zone.size_min or config.size_min or defs.size_min
	local size_max = zone.size_max or config.size_max or defs.size_max
	local size_variation = zone.size_variation or config.size_variation or defs.size_variation
	local color = zone.color or config.color or defs.color
	self.blend_mode = zone.blend_mode or config.blend_mode or defs.blend_mode

	local drift_x_min, drift_x_max = resolve_range(drift_x, defs.drift_x)
	local gravity_min, gravity_max = resolve_range(gravity, defs.gravity)
	local linear_accel_min_x = zone.linear_accel_min_x or drift_x_min
	local linear_accel_max_x = zone.linear_accel_max_x or drift_x_max
	local linear_accel_min_y = zone.linear_accel_min_y or gravity_min
	local linear_accel_max_y = zone.linear_accel_max_y or gravity_max

	local emission_mode = zone.emission_mode or config.emission_mode or "borderrectangle"
	local w = zone.w or config.width or 1
	local h = zone.h or emission_height
	local x = zone.x or 0
	local y = zone.y or 0

	self.emission_mode = emission_mode
	self.emission_w = w
	self.emission_h = h
	self.x = x + w / 2
	self.y = y + h / 2

	local ps = lg.newParticleSystem(shared_image, BUFFER)

	ps:setInsertMode("random")
	ps:setColors(colors_from_base(color))
	ps:setDirection(direction)
	ps:setEmissionArea(emission_mode, w, h, 0, false)
	ps:setEmissionRate(emission_rate)
	ps:setEmitterLifetime(-1)
	ps:setLinearAcceleration(
		linear_accel_min_x,
		linear_accel_min_y,
		linear_accel_max_x,
		linear_accel_max_y
	)
	ps:setLinearDamping(0, 0)
	ps:setOffset(TEXTURE_SIZE / 2, TEXTURE_SIZE / 2)
	ps:setRadialAcceleration(0, 0)
	ps:setRelativeRotation(false)
	ps:setRotation(0, 0)
	ps:setSpin(
		zone.spin_min or config.spin_min or defs.spin_min,
		zone.spin_max or config.spin_max or defs.spin_max
	)
	ps:setSpinVariation(zone.spin_variation or config.spin_variation or defs.spin_variation)
	ps:setSpread(spread)
	ps:setTangentialAcceleration(0, 0)
	ps:setParticleLifetime(lifetime_min, lifetime_max)
	ps:setSizes(size_min, size_max * 0.85, size_max * 0.5, 0)
	ps:setSizeVariation(size_variation)
	ps:setSpeed(speed_min, speed_max)

	self.system = ps
	ps:emit(math.min(BUFFER, math.floor(emission_rate * 6)))
end

function PSAtmosphericSpecs:get_emission_rect(draw_x, draw_y)
	local cx = draw_x or self.x
	local cy = draw_y or self.y
	return cx - self.emission_w * 0.5, cy - self.emission_h * 0.5, self.emission_w, self.emission_h
end

function PSAtmosphericSpecs:update(dt)
	assert:type(dt, "number")
	if self.system then
		self.system:update(dt)
	end
end

function PSAtmosphericSpecs:draw(x, y)
	if not self.system or self.system:getCount() == 0 then
		return
	end

	lg.setBlendMode(self.blend_mode)
	lg.draw(self.system, x or self.x, y or self.y)
end

return PSAtmosphericSpecs
