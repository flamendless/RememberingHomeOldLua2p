local AtmosphericSpecs = Concord.system()

function AtmosphericSpecs:init(world)
	self.world = world
	self.instances = {}
end

function AtmosphericSpecs:clear()
	self.instances = {}
end

local function build_zones(config)
	if config.zones then
		return config.zones
	end

	return {
		{
			x = 0,
			y = 0,
			w = config.width,
			h = config.emission_height or 8,
			direction = config.direction,
			direction_offset = config.direction_offset,
			drift_x = config.drift_x,
			gravity = config.gravity,
			speed = config.speed,
			spread = config.spread,
			emission_rate = config.emission_rate,
			lifetime = config.lifetime,
			particle_lifetime_min = config.particle_lifetime_min,
			particle_lifetime_max = config.particle_lifetime_max,
			color = config.color,
			size_min = config.size_min,
			size_max = config.size_max,
			size_variation = config.size_variation,
			spin_min = config.spin_min,
			spin_max = config.spin_max,
			spin_variation = config.spin_variation,
			linear_accel_min_x = config.linear_accel_min_x,
			linear_accel_min_y = config.linear_accel_min_y,
			linear_accel_max_x = config.linear_accel_max_x,
			linear_accel_max_y = config.linear_accel_max_y,
			blend_mode = config.blend_mode,
		},
	}
end

function AtmosphericSpecs:setup_atmospheric_specs(config)
	self:clear()
	if not config or not config.enabled then
		return
	end

	local zones = build_zones(config)
	for _, zone in ipairs(zones) do
		local zone_config = tablex.copy(zone)
		zone_config.width = config.width
		zone_config.height = config.height
		if not zone_config.color and config.color then
			zone_config.color = config.color
		end
		if not zone_config.blend_mode and config.blend_mode then
			zone_config.blend_mode = config.blend_mode
		end
		self.instances[#self.instances + 1] = ParticleSystems.AtmosphericSpecs(zone_config)
	end

	Log.info("Setup atmospheric specs:", #self.instances, "zone(s)")
end

function AtmosphericSpecs:create_room_bounds(w, h, opt)
	assert:type(w, "number")
	assert:type(h, "number")
	assert:type_or_nil(opt, "table")

	local room_id = opt and opt.scene_id
	local config = Data.AtmosphericSpecs.get(room_id)
	config.width = w
	config.height = h
	self:setup_atmospheric_specs(config)
end

function AtmosphericSpecs:update(dt)
	assert:type(dt, "number")
	for _, ps in ipairs(self.instances) do
		ps:update(dt)
	end
end

function AtmosphericSpecs:draw_atmospheric_specs()
	love.graphics.setColor(1, 1, 1, 1)
	for _, ps in ipairs(self.instances) do
		ps:draw()
	end
	love.graphics.setBlendMode("alpha")
end

return AtmosphericSpecs
