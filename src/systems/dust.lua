local Dust = Concord.system({
	pool = { "id", "dust", "pos", "size" },
})

local CEILING_ENTITY_PADDING = 64

local FOOT_BURST_DEFAULTS = {
	w = 24,
	h = 4,
	color = Palette.get("dust", 1),
	size = 1.0,
	strength = 0.4,
	strength_walk = 0.4,
	strength_run = 0.8,
	size_variation = 0.5,
	direction_lift = 0.35,
	particle_lifetime_min = 0.3,
	particle_lifetime_max = 0.65,
	emitter_lifetime = 0.2,
	emit_at_start = 16,
}

local CEILING_BURST_DEFAULTS = {
	direction = math.pi / 2,
	color = Palette.get("dust", 1),
	size = 1.1,
	strength = 0.9,
	size_variation = 0.5,
	particle_lifetime_min = 0.4,
	particle_lifetime_max = 1.2,
	emitter_lifetime = 0.35,
	emit_at_start = 24,
}

function Dust:init(world)
	self.world = world
	self.bursts = ParticleSystems.Dust()
	self.active = {}

	if DEV then
		self.debug_show_bbox = true
		self.debug_selected_key = nil
		self.debug_test_counter = 0
		self.debug_default_region = { x = 200, y = 8, w = 200, h = 8 }
	end

	self.pool.onRemoved = function(_, e)
		self.active[e] = nil
		if DEV and self.debug_selected_key and e:has("key") then
			if e:get("key").value == self.debug_selected_key then
				self.debug_selected_key = nil
			end
		end
	end
end

function Dust:resolve_entity(key)
	assert:type(key, "string")
	local e = self.world:getEntityByKey(key)
	assert(e, "dust: entity not found: " .. key)
	return e
end

function Dust:build_config(e)
	assert(e.__isEntity and e:has("dust") and e:has("pos") and e:has("size"), e)
	local pos = e:get("pos")
	local size = e:get("size")
	local dust = e:get("dust")

	return {
		x = pos.x,
		y = pos.y,
		w = size.w,
		h = size.h,
		direction = dust.direction,
		color = dust.color,
		size = dust.size,
		strength = dust.strength,
		size_variation = dust.size_variation,
	}
end

function Dust:trigger_dust(e)
	assert(e.__isEntity and e:has("dust"), e)
	if e:has("hidden") then
		return
	end

	local burst = self.bursts:trigger(self:build_config(e))
	self.active[e] = burst
end

function Dust:merge_burst_config(config, defaults)
	assert:type_or_nil(config, "table")
	assert:type(defaults, "table")
	config = config or {}
	return {
		x = config.x or 0,
		y = config.y or 0,
		w = config.w or defaults.w or 8,
		h = config.h or defaults.h or 4,
		direction = config.direction or defaults.direction,
		color = config.color or defaults.color,
		size = config.size or defaults.size,
		strength = config.strength or defaults.strength,
		size_variation = config.size_variation or defaults.size_variation,
		direction_lift = config.direction_lift or defaults.direction_lift,
		particle_lifetime_min = config.particle_lifetime_min or defaults.particle_lifetime_min,
		particle_lifetime_max = config.particle_lifetime_max or defaults.particle_lifetime_max,
		emitter_lifetime = config.emitter_lifetime or defaults.emitter_lifetime,
		emit_at_start = config.emit_at_start or defaults.emit_at_start,
	}
end

function Dust:floor_y_at(px)
	assert:type(px, "number")
	local bump = self.world:getSystem(ECS.get_system_class("bump_collision"))
	if not bump then
		return nil
	end

	for _, e in ipairs(bump.pool:getItems()) do
		if e:has("ground") then
			local gx, gy, gw, _ = bump.pool:getRect(e)
			if px >= gx and px <= gx + gw then
				return gy
			end
		end
	end

	return nil
end

function Dust:entity_move_dx(e)
	assert(e.__isEntity and e:has("body"), e)
	local body = e:get("body")
	if body.dx ~= 0 then
		return body.dx
	end

	if body.vel_x and body.vel_x ~= 0 then
		return body.vel_x > 0 and 1 or -1
	end

	local transform = e:get("transform")
	if transform then
		return transform.sx < 0 and -1 or 1
	end

	return 0
end

function Dust:entity_foot_direction(e, lift)
	assert(e.__isEntity and e:has("body"), e)
	assert:type_or_nil(lift, "number")
	lift = lift or FOOT_BURST_DEFAULTS.direction_lift or 0.35
	local dx = self:entity_move_dx(e)
	if dx > 0 then
		return math.pi - lift
	end
	if dx < 0 then
		return -lift
	end
	return math.pi - lift
end

function Dust:entity_foot_region(e)
	assert(e.__isEntity and e:has("pos") and e:has("collider"), e)

	local pos = e:get("pos")
	local collider = e:get("collider")
	local _, oy = 0, 0
	if e:has("collider_offset") then
		local offset = e:get("collider_offset")
		-- ox = offset.ox
		oy = offset.oy
	end

	local bump = self.world:getSystem(ECS.get_system_class("bump_collision"))
	local rx, _, rw, _ = bump.pool:getRect(e)
	local foot_x = rx + rw / 2

	local w = FOOT_BURST_DEFAULTS.w
	local h = FOOT_BURST_DEFAULTS.h
	local foot_y = pos.y + oy + collider.h
	local floor_y = self:floor_y_at(foot_x)
	if floor_y then
		foot_y = floor_y
	end

	return {
		x = rx + (rw - w) / 2,
		y = foot_y - h,
		w = w,
		h = h,
	}
end

function Dust:foot_strength(e)
	assert(e.__isEntity, e)
	if e:has("is_running") then
		local is_running = e:get("is_running")
		if is_running.value then
			return FOOT_BURST_DEFAULTS.strength_run
		end
	end
	return FOOT_BURST_DEFAULTS.strength_walk
end

function Dust:current_scene_id()
	local scene_id = self.world:getResource("scene_id")
	if scene_id then
		return scene_id
	end

	local room = self.world:getSystem(ECS.get_system_class("room"))
	if room and room.current_res then
		return room.current_res
	end

	return nil
end

function Dust:entity_ceiling_region(e)
	assert(e.__isEntity and e:has("pos"), e)

	local scene_id = self:current_scene_id()
	local room = scene_id and Data.RoomBounds[scene_id]
	assert(room, "dust: no room bounds for scene: " .. tostring(scene_id))

	local ceiling = room.ceiling
	local h = ceiling.emitter_h
	local y = ceiling.bottom_y - h

	local pos = e:get("pos")
	local padding = CEILING_ENTITY_PADDING
	local w = padding
	local half = w / 2
	local cx = pos.x + (love.math.random() * 2 - 1) * padding
	local x = cx - half

	return {
		x = x,
		y = y,
		w = w,
		h = h,
	}
end

function Dust:trigger_dust_burst(kind, key)
	assert(Enums.dust_kind[kind], kind)
	assert:type(key, "string")

	if kind == Enums.dust_kind.emitter then
		local e = self:resolve_entity(key)
		assert(e:has("dust"), key)
		return self:trigger_dust(e)
	end

	local e = self:resolve_entity(key)

	if kind == Enums.dust_kind.foot then
		local region = self:entity_foot_region(e)
		local config = self:merge_burst_config({
			x = region.x,
			y = region.y,
			w = region.w,
			h = region.h,
			strength = self:foot_strength(e),
			direction = self:entity_foot_direction(e, FOOT_BURST_DEFAULTS.direction_lift),
		}, FOOT_BURST_DEFAULTS)
		return self.bursts:trigger(config)
	end

	if kind == Enums.dust_kind.ceiling then
		local region = self:entity_ceiling_region(e)
		local config = self:merge_burst_config({
			x = region.x,
			y = region.y,
			w = region.w,
			h = region.h,
		}, CEILING_BURST_DEFAULTS)
		return self.bursts:trigger(config)
	end
end

function Dust:update(dt)
	assert:type(dt, "number")
	self.bursts:update(dt)

	for e, burst in pairs(self.active) do
		if not burst:is_alive() then
			self.active[e] = nil
		end
	end
end

function Dust:draw_dust()
	self.bursts:draw()
end

if DEV then
	function Dust:get_selected_emitter()
		if not self.debug_selected_key then
			return nil
		end
		return self.world:getEntityByKey(self.debug_selected_key)
	end

	function Dust:spawn_test_emitter()
		self.debug_test_counter = self.debug_test_counter + 1
		local key = "dust_test_" .. self.debug_test_counter
		local region = self.debug_default_region

		local e = Concord.entity(self.world):assemble(
			Assemblages.Dust.emitter,
			key,
			region.x,
			region.y,
			region.w,
			region.h
		)

		self.debug_selected_key = key
		return e
	end

	function Dust:debug_update(dt)
		assert:type(dt, "number")
		if not self.debug_show then
			return
		end

		self.debug_show = Slab.BeginWindow("dust", {
			Title = "Dust",
			IsOpen = self.debug_show,
		})

		if Slab.CheckBox(self.debug_show_bbox, "draw bounding box") then
			self.debug_show_bbox = not self.debug_show_bbox
		end

		Slab.Separator()
		Slab.Text("Emitter:")

		if Slab.BeginComboBox("cb_dust_emitter", { Selected = self.debug_selected_key }) then
			for _, e in ipairs(self.pool) do
				local key = e:get("key").value
				if Slab.TextSelectable(key) then
					self.debug_selected_key = key
					break
				end
			end
			Slab.EndComboBox()
		end

		Slab.SameLine()
		if Slab.Button("Spawn test emitter") then
			self:spawn_test_emitter()
		end

		local e = self:get_selected_emitter()
		if e then
			local pos = e:get("pos")
			local size = e:get("size")
			local dust = e:get("dust")

			pos.x = UIWrapper.edit_range("x", pos.x, 0, 2048, true)
			pos.y = UIWrapper.edit_range("y", pos.y, 0, 2048, true)
			size.w = UIWrapper.edit_range("w", size.w, 1, 2048, true)
			size.h = UIWrapper.edit_range("h", size.h, 1, 2048, true)

			dust.size = UIWrapper.edit_range("dust size", dust.size, 0.1, 8, false)
			dust.strength = UIWrapper.edit_range("strength", dust.strength, 0, 4, false)
			dust.direction = UIWrapper.edit_range("direction", dust.direction, -math.pi, math.pi, false)
			dust.size_variation = UIWrapper.edit_range("size variation", dust.size_variation, 0, 1, false)
			UIWrapper.color(dust.color)

			if Slab.Button("Trigger Dust") then
				self:trigger_dust_burst(Enums.dust_kind.emitter, self.debug_selected_key)
			end
		else
			Slab.Text("No emitter selected")
		end

		Slab.EndWindow()
	end

	function Dust:debug_draw()
		if not self.debug_show or not self.debug_show_bbox then
			return
		end

		love.graphics.setLineWidth(1)
		for _, e in ipairs(self.pool) do
			local pos = e:get("pos")
			local size = e:get("size")
			local key = e:get("key").value
			local selected = key == self.debug_selected_key

			if selected then
				love.graphics.setColor(1, 1, 0, 0.9)
			else
				love.graphics.setColor(1, 1, 1, 0.5)
			end
			love.graphics.rectangle("line", pos.x, pos.y, size.w, size.h)
		end
		love.graphics.setColor(1, 1, 1, 1)
	end

	function Dust.slab_dust(e)
		assert(e.__isEntity and e:has("dust"), e)
		local dust = e:get("dust")
		dust.size = UIWrapper.edit_range("dust size", dust.size, 0.1, 8, false)
		dust.strength = UIWrapper.edit_range("strength", dust.strength, 0, 4, false)
		dust.direction = UIWrapper.edit_range("direction", dust.direction, -math.pi, math.pi, false)
		dust.size_variation = UIWrapper.edit_range("size variation", dust.size_variation, 0, 1, false)
		UIWrapper.color(dust.color)
	end

	DevTools.register_slab_component("dust", Dust.slab_dust)
end

return Dust
