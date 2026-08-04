local LightWindPass = Concord.system()

local DEFAULT_EXCLUDE_GROUPS = {
	[Enums.light_group.player_flashlight] = true,
}

local function group_allowed(e, opts)
	if e:has("flashlight") or e:has("flame") then
		if not opts.include_flames then
			return false
		end
	end

	if opts.groups then
		if not e:has("light_group") then
			return false
		end
		local g = e:get("light_group").value
		for _, name in ipairs(opts.groups) do
			if g == name then
				return true
			end
		end
		return false
	end

	if e:has("light_group") then
		local g = e:get("light_group").value
		if opts.exclude then
			for _, name in ipairs(opts.exclude) do
				if g == name then
					return false
				end
			end
		end
		if DEFAULT_EXCLUDE_GROUPS[g] then
			return false
		end
	end

	return true
end

function LightWindPass:init(world)
	self.world = world
	self.pass_token = 0
	self.active_pass = false
	self.pass_restore = {}
end

function LightWindPass:collect_lights(dl, opts)
	local lights = {}
	for _, e in ipairs(dl.pool) do
		if not e:has("light_disabled") and group_allowed(e, opts) then
			lights[#lights + 1] = e
		end
	end

	local direction = opts.direction or "left"
	table.sort(lights, function(a, b)
		local ax = a:get("pos").x
		local bx = b:get("pos").x
		if direction == "right" then
			return ax > bx
		end
		return ax < bx
	end)

	return lights
end

function LightWindPass:dim_target(base, strength)
	strength = strength or 0.85
	return {
		base[1] * (1 - strength),
		base[2] * (1 - strength),
		base[3] * (1 - strength),
		base[4] or 1,
	}
end

function LightWindPass:snapshot_light(e)
	if self.pass_restore[e] then
		return
	end

	local diffuse = e:get("diffuse")
	local snapshot = {
		diffuse = { unpack(diffuse.value) },
		disabled = e:has("light_disabled"),
	}

	if e:has("d_light_flicker") then
		local flicker = e:get("d_light_flicker")
		snapshot.flicker = { flicker.during, flicker.on_chance, flicker.off_chance }
		if e:has("d_light_flicker_repeat") then
			local repeat_f = e:get("d_light_flicker_repeat")
			snapshot.flicker_repeat = { repeat_f.count, repeat_f.delay }
		end
		if e:has("d_light_flicker_remove_after") then
			snapshot.flicker_remove_after = true
		end
		if e:has("d_light_flicker_sure_on_after") then
			snapshot.flicker_sure_on_after = true
		end
		if e:has("on_d_light_flicker_during") then
			local signal = e:get("on_d_light_flicker_during")
			snapshot.flicker_during = { signal.signal, signal.delay, unpack(signal.args) }
		end
		if e:has("on_d_light_flicker_after") then
			local signal = e:get("on_d_light_flicker_after")
			snapshot.flicker_after = { signal.signal, signal.delay, unpack(signal.args) }
		end
	end

	self.pass_restore[e] = snapshot
end

function LightWindPass:clear_flicker(dl, e)
	dl:stop_flicker(e)
end

function LightWindPass:restore_flicker(e, snapshot)
	if not snapshot.flicker then
		return
	end

	e:give("d_light_flicker", unpack(snapshot.flicker))
	if snapshot.flicker_repeat then
		e:give("d_light_flicker_repeat", unpack(snapshot.flicker_repeat))
	end
	if snapshot.flicker_remove_after then
		e:give("d_light_flicker_remove_after")
	end
	if snapshot.flicker_sure_on_after then
		e:give("d_light_flicker_sure_on_after")
	end
	if snapshot.flicker_during then
		e:give("on_d_light_flicker_during", unpack(snapshot.flicker_during))
	end
	if snapshot.flicker_after then
		e:give("on_d_light_flicker_after", unpack(snapshot.flicker_after))
	end
end

function LightWindPass:restore_all_lights(dl)
	for e, snapshot in pairs(self.pass_restore) do
		if e:has("diffuse") then
			local diffuse = e:get("diffuse")
			Flux.remove(diffuse.value)
			self:clear_flicker(dl, e)

			diffuse.value[1] = snapshot.diffuse[1]
			diffuse.value[2] = snapshot.diffuse[2]
			diffuse.value[3] = snapshot.diffuse[3]
			if snapshot.diffuse[4] ~= nil then
				diffuse.value[4] = snapshot.diffuse[4]
			end

			if snapshot.disabled then
				e:give("light_disabled")
			else
				e:remove("light_disabled")
			end

			dl:update_light_diffuse(e)
			self:restore_flicker(e, snapshot)
		end
	end

	self.pass_restore = {}
end

function LightWindPass:apply_instant(dl, e, opts)
	local diffuse = e:get("diffuse")
	local target = self:dim_target(diffuse.value, opts.strength)

	diffuse.value[1] = target[1]
	diffuse.value[2] = target[2]
	diffuse.value[3] = target[3]
	dl:update_light_diffuse(e)
end

function LightWindPass:apply_dim(dl, e, opts)
	local diffuse = e:get("diffuse")
	local target = self:dim_target(diffuse.value, opts.strength)
	local ramp = opts.recover or 0.3

	Flux.to(diffuse.value, ramp, {
		[1] = target[1],
		[2] = target[2],
		[3] = target[3],
	}):onupdate(function()
		dl:update_light_diffuse(e)
	end)
end

function LightWindPass:apply_flicker(dl, e, opts)
	self:clear_flicker(dl, e)

	local during = opts.flicker_during or 0.2
	local on_chance = opts.flicker_on or 0.25
	local off_chance = opts.flicker_off or 0.75

	e:give("d_light_flicker", during, on_chance, off_chance)
		:give("d_light_flicker_remove_after")
end

function LightWindPass:affect_light(dl, e, opts, mode)
	self:snapshot_light(e)

	if mode == "instant" then
		self:apply_instant(dl, e, opts)
	elseif mode == "dim" then
		self:apply_dim(dl, e, opts)
	else
		self:apply_flicker(dl, e, opts)
	end

	if opts.affect_flames then
		local pos = e:get("pos")
		local strength = opts.wind_strength or 4
		local radius = opts.wind_radius or 120
		self.world:emit("on_blow_wind", strength, pos.x, pos.y, radius)
	end
end

function LightWindPass:play_pass_sound(opts)
	local sound = opts.sound
	if not sound then
		return
	end
	self.world:emit("play_event_sound", sound)
end

function LightWindPass:wind_pass_lights(opts)
	opts = opts or {}

	local dl = self.world:getSystem(ECS.get_system_class("deferred_lighting"))
	if not dl then
		return
	end

	if self.active_pass then
		self.pass_token = self.pass_token + 1
		self:restore_all_lights(dl)
		self.active_pass = false
	end

	local lights = self:collect_lights(dl, opts)
	if #lights == 0 then
		return
	end

	self.active_pass = true
	self.pass_token = self.pass_token + 1
	local token = self.pass_token
	self.pass_restore = {}

	local mode = opts.mode or "flicker"
	local stagger = opts.stagger or 0.1
	local hold = opts.hold or 0.4
	local recover = opts.recover or 0.6
	local flicker_during = opts.flicker_during or 0.2

	if opts.sound and (not opts.sound_timing or opts.sound_timing == "start") then
		self:play_pass_sound(opts)
	end

	for i, e in ipairs(lights) do
		GameStates.after((i - 1) * stagger, function()
			if token ~= self.pass_token then
				return
			end
			if opts.sound and opts.sound_timing == "each" then
				self:play_pass_sound(opts)
			end
			self:affect_light(dl, e, opts, mode)
		end)
	end

	local tail = (#lights - 1) * stagger
	if mode == "dim" then
		tail = tail + recover
	elseif mode == "instant" then
		tail = tail + hold
	else
		tail = tail + flicker_during
	end

	GameStates.after(tail, function()
		if token ~= self.pass_token then
			return
		end
		self:restore_all_lights(dl)
		self.active_pass = false
	end)
end

return LightWindPass
