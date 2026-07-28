local lg = love.graphics

local HP = {
	direction = -1.5707963705063,
	spread = 1.8550356626511,
	speed_min = 19.618450164795,
	speed_max = 251.52854919434,
	lifetime_min = 0.13734957575798,
	lifetime_max = 0.34939830303192,
	size = 0.55240023136139,
	size_variation = 0.45047923922539,
	linear_damping_min = -0.31050637364388,
	linear_damping_max = 0.71063297986984,
	emitter_offset_x = 1.3605442176871,
	emitter_offset_y = 0,
	emit_count = 9,
}

local POOL_SIZE = 8
local TEXTURE_SIZE = 8
local BUFFER = HP.emit_count + 8

local PRESETS = {
	[Enums.lighter_spark_intensity.subtle] = {
		id = Enums.lighter_spark_intensity.subtle,
		emit_count = 4,
		speed_scale = 0.45,
		size_scale = 0.65,
		spread_scale = 0.7,
	},
	[Enums.lighter_spark_intensity.strong] = {
		id = Enums.lighter_spark_intensity.strong,
		emit_count = HP.emit_count,
		speed_scale = 0.6,
		size_scale = 0.77,
		spread_scale = 0.9,
	},
}

local function generate_light_dot_texture(size)
	local data = love.image.newImageData(size, size)
	local cx, cy = size / 2, size / 2
	local max_dist = math.sqrt(cx * cx + cy * cy)

	data:mapPixel(function(x, y)
		local dx = x - cx
		local dy = y - cy
		local dist = math.sqrt(dx * dx + dy * dy)
		local normalized = dist / max_dist
		local intensity = math.exp(-(normalized * normalized) * 4)
		return 1, 1, 1, intensity
	end)

	local image = lg.newImage(data)
	image:setFilter("nearest", "nearest")
	return image
end

local PSLighterSpark = class({
	name = "PSLighterSpark",
})

function PSLighterSpark:new(image)
	assert(image:type() == "Image", image)
	self.image = image
	self.system = nil
	self.blend_mode = "alpha"
	self.x = 0
	self.y = 0
	self.emit_count = 0
	self.preset_id = Enums.lighter_spark_intensity.subtle
end

function PSLighterSpark:create_system()
	local ps = lg.newParticleSystem(self.image, BUFFER)

	ps:setEmissionRate(0)
	ps:setEmitterLifetime(-1)
	ps:setEmissionArea("none", 0, 0, 0, false)
	ps:setInsertMode("top")
	ps:setLinearAcceleration(0, 0, 0, 0)
	ps:setLinearDamping(HP.linear_damping_min, HP.linear_damping_max)
	ps:setOffset(TEXTURE_SIZE / 2, TEXTURE_SIZE / 2)
	ps:setRadialAcceleration(0, 0)
	ps:setRelativeRotation(false)
	ps:setRotation(0, 0)
	ps:setSpin(0, 0)
	ps:setSpinVariation(0)
	ps:setTangentialAcceleration(0, 0)

	return ps
end

function PSLighterSpark:configure(tier_color, dir, preset)
	self.system = self:create_system()
	local ps = self.system

	ps:setColors(Palette.spark_colors_from_tier(tier_color))
	ps:setDirection(HP.direction + (dir or 1) * 0.2)
	ps:setSpread(HP.spread * preset.spread_scale)
	ps:setSpeed(
		HP.speed_min * preset.speed_scale,
		HP.speed_max * preset.speed_scale
	)
	ps:setParticleLifetime(HP.lifetime_min, HP.lifetime_max)
	ps:setSizes(HP.size * preset.size_scale)
	ps:setSizeVariation(HP.size_variation)

	self.emit_count = preset.emit_count
	self.preset_id = preset.id
end

function PSLighterSpark:burst(x, y, dir)
	self.x = x + HP.emitter_offset_x * (dir or 1)
	self.y = y + HP.emitter_offset_y
	self.system:emit(self.emit_count)
	Log.debug(
		"lighter spark emit",
		self.preset_id,
		"count=" .. self.emit_count,
		"alive=" .. self.system:getCount(),
		"x=" .. self.x,
		"y=" .. self.y,
		"dir=" .. (dir or 1)
	)
end

function PSLighterSpark:update(dt)
	if not self.system or self.system:getCount() == 0 then
		return
	end

	self.system:update(dt)
end

function PSLighterSpark:is_alive()
	return self.system and self.system:getCount() > 0
end

function PSLighterSpark:draw(x, y)
	if not self:is_alive() then
		return
	end

	lg.setBlendMode(self.blend_mode)
	lg.draw(self.system, x or self.x, y or self.y)
end

local LighterSparkPool = class({
	name = "LighterSparkPool",
})

function LighterSparkPool:new()
	self.image = generate_light_dot_texture(TEXTURE_SIZE)
	self.pool = {}
	for _ = 1, POOL_SIZE do
		table.insert(self.pool, PSLighterSpark(self.image))
	end
end

function LighterSparkPool:acquire()
	return self.pool[love.math.random(1, #self.pool)]
end

function LighterSparkPool:burst_subtle(x, y, dir, tier_color)
	local burst = self:acquire()
	burst:configure(tier_color, dir, PRESETS[Enums.lighter_spark_intensity.subtle])
	burst:burst(x, y, dir)
end

function LighterSparkPool:burst_strong(x, y, dir, tier_color)
	local burst = self:acquire()
	burst:configure(tier_color, dir, PRESETS[Enums.lighter_spark_intensity.strong])
	burst:burst(x, y, dir)
end

function LighterSparkPool:update(dt)
	for _, burst in ipairs(self.pool) do
		burst:update(dt)
	end
end

function LighterSparkPool:draw()
	lg.setColor(1, 1, 1, 1)
	for _, burst in ipairs(self.pool) do
		burst:draw()
	end
	lg.setBlendMode("alpha")
end

return LighterSparkPool
