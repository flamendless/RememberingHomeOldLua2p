local AtmosphericSpecs = Concord.system()

function AtmosphericSpecs:init(world)
	self.world = world
	self.instances = {}
end

function AtmosphericSpecs:clear()
	self.instances = {}
end

local function zone_fields_from_config(config)
	return {
		emission_mode = config.emission_mode,
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
	}
end

local function build_zone(config, geometry)
	local zone = zone_fields_from_config(config)
	zone.x = geometry.x
	zone.y = geometry.y
	zone.w = geometry.w
	zone.h = geometry.h
	return zone
end

local function build_zones(config)
	if config.zones then
		return config.zones
	end

	if config.zone_y_start then
		local y = config.height * config.zone_y_start
		return {
			build_zone(config, {
				x = 0,
				y = y,
				w = config.width,
				h = config.height - y,
			}),
		}
	end

	return {
		build_zone(config, {
			x = 0,
			y = 0,
			w = config.width,
			h = config.emission_height or 8,
		}),
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

function AtmosphericSpecs:setup_for_scene(w, h, opt)
	assert:type(w, "number")
	assert:type(h, "number")
	assert:type_or_nil(opt, "table")

	local room_id = opt and opt.scene_id
	local config = Data.AtmosphericSpecs.get(room_id)
	config.width = w
	config.height = h
	self:setup_atmospheric_specs(config)
end

function AtmosphericSpecs:create_room_bounds(w, h, opt)
	self:setup_for_scene(w, h, opt)
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

if DEV then
	local BLEND_MODES = { "alpha", "add", "multiply", "lighten" }

	local function format_range(range)
		return string.format("{ min = %s, max = %s }", range.min, range.max)
	end

	local function format_color(color)
		return string.format(
			"{ %s, %s, %s, %s }",
			color[1],
			color[2],
			color[3],
			color[4] or 1
		)
	end

	local function print_config(cfg)
		print("AtmosphericSpecs config = {")
		print("  enabled = " .. tostring(cfg.enabled) .. ",")
		print("  direction_offset = " .. cfg.direction_offset .. ",")
		print("  drift_x = " .. format_range(cfg.drift_x) .. ",")
		print("  gravity = " .. format_range(cfg.gravity) .. ",")
		print("  speed = " .. format_range(cfg.speed) .. ",")
		print("  spread = " .. cfg.spread .. ",")
		print("  emission_rate = " .. cfg.emission_rate .. ",")
		print("  emission_height = " .. cfg.emission_height .. ",")
		print("  lifetime = " .. format_range(cfg.lifetime) .. ",")
		print("  size_min = " .. cfg.size_min .. ",")
		print("  size_max = " .. cfg.size_max .. ",")
		print("  size_variation = " .. cfg.size_variation .. ",")
		print("  spin_min = " .. cfg.spin_min .. ",")
		print("  spin_max = " .. cfg.spin_max .. ",")
		print("  spin_variation = " .. cfg.spin_variation .. ",")
		print("  color = " .. format_color(cfg.color) .. ",")
		print('  blend_mode = "' .. cfg.blend_mode .. '",')
		print("}")
	end

	function AtmosphericSpecs:debug_load_config()
		local scene_id = self.world:getResource("scene_id")
		self.debug_config = Data.AtmosphericSpecs.get(scene_id)
		local room_size = self.world:getResource("room_size")
		if room_size then
			self.debug_config.width = room_size.width
			self.debug_config.height = room_size.height
		end
	end

	function AtmosphericSpecs:debug_apply_config()
		if not self.debug_config then
			self:debug_load_config()
		end

		local room_size = self.world:getResource("room_size")
		if room_size then
			self.debug_config.width = room_size.width
			self.debug_config.height = room_size.height
		end

		self:setup_atmospheric_specs(self.debug_config)
	end

	function AtmosphericSpecs:debug_update(dt)
		assert:type(dt, "number")
		if not self.debug_show then
			return
		end

		self.debug_show = Slab.BeginWindow("atmospheric_specs", {
			Title = "Atmospheric Specs",
			IsOpen = self.debug_show,
		})

		if not self.debug_config then
			self:debug_load_config()
		end

		local cfg = self.debug_config
		local changed = false

		Slab.Text("Zones: " .. #self.instances)

		if Slab.Button("Reload from data") then
			self:debug_load_config()
			self:debug_apply_config()
		end
		Slab.SameLine()
		if Slab.Button("Apply") then
			self:debug_apply_config()
		end
		Slab.SameLine()
		if Slab.Button("Print config") then
			print_config(cfg)
		end

		if Slab.CheckBox(cfg.enabled, "enabled") then
			cfg.enabled = not cfg.enabled
			changed = true
		end

		local direction_offset, direction_changed = UIWrapper.edit_range(
			"direction offset",
			cfg.direction_offset,
			-math.pi,
			math.pi
		)
		cfg.direction_offset = direction_offset
		changed = changed or direction_changed

		if UIWrapper.edit_range_table("drift x", cfg.drift_x, -64, 64) then
			changed = true
		end
		if UIWrapper.edit_range_table("gravity", cfg.gravity, -64, 64) then
			changed = true
		end
		if UIWrapper.edit_range_table("speed", cfg.speed, 0, 64) then
			changed = true
		end

		local spread, spread_changed = UIWrapper.edit_range("spread", cfg.spread, 0, math.pi)
		cfg.spread = spread
		changed = changed or spread_changed

		local emission_rate, emission_rate_changed = UIWrapper.edit_range(
			"emission rate",
			cfg.emission_rate,
			0,
			200
		)
		cfg.emission_rate = emission_rate
		changed = changed or emission_rate_changed

		local emission_height, emission_height_changed = UIWrapper.edit_range(
			"emission height",
			cfg.emission_height,
			1,
			256,
			true
		)
		cfg.emission_height = emission_height
		changed = changed or emission_height_changed

		if UIWrapper.edit_range_table("lifetime", cfg.lifetime, 0.1, 30) then
			changed = true
		end

		local size_min, size_min_changed = UIWrapper.edit_range("size min", cfg.size_min, 0.01, 8)
		cfg.size_min = size_min
		changed = changed or size_min_changed

		local size_max, size_max_changed = UIWrapper.edit_range("size max", cfg.size_max, 0.01, 8)
		cfg.size_max = size_max
		changed = changed or size_max_changed

		local size_variation, size_variation_changed = UIWrapper.edit_range(
			"size variation",
			cfg.size_variation,
			0,
			1
		)
		cfg.size_variation = size_variation
		changed = changed or size_variation_changed

		local spin_min, spin_min_changed = UIWrapper.edit_range("spin min", cfg.spin_min, -4, 4)
		cfg.spin_min = spin_min
		changed = changed or spin_min_changed

		local spin_max, spin_max_changed = UIWrapper.edit_range("spin max", cfg.spin_max, -4, 4)
		cfg.spin_max = spin_max
		changed = changed or spin_max_changed

		local spin_variation, spin_variation_changed = UIWrapper.edit_range(
			"spin variation",
			cfg.spin_variation,
			0,
			1
		)
		cfg.spin_variation = spin_variation
		changed = changed or spin_variation_changed

		UIWrapper.color(cfg.color)

		Slab.Text("blend mode:")
		Slab.SameLine()
		if Slab.BeginComboBox("atmospheric_specs_blend", { Selected = cfg.blend_mode }) then
			for _, mode in ipairs(BLEND_MODES) do
				if Slab.TextSelectable(mode) then
					cfg.blend_mode = mode
					changed = true
					break
				end
			end
			Slab.EndComboBox()
		end

		if changed then
			self:debug_apply_config()
		end

		Slab.EndWindow()
	end

	function AtmosphericSpecs:debug_draw()
		if not self.debug_show or #self.instances == 0 then
			return
		end

		local camera = self.world:getResource("camera")
		local scale = camera and camera:getScale() or 1
		love.graphics.setLineWidth(1 / scale)
		love.graphics.setColor(1, 1, 1, 1)
		for _, ps in ipairs(self.instances) do
			local x, y, w, h = ps:get_emission_rect()
			love.graphics.rectangle("line", x, y, w, h)
		end
		love.graphics.setColor(1, 1, 1, 1)
	end
end

return AtmosphericSpecs
