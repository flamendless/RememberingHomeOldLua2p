local Tutorial = Concord.system({})

local PRESS_HAND_PROGRESS_OPTS = {
	animate_frame = false,
	fade_opacity = true,
}

local MAX_HOLD_INTERACT_TIMER = 3
local OPEN_LIGHTER_FLAME_FRAME = 8

local OPEN_LIGHTER_TAGS = {
	[Enums.anim_state.open_lighter] = true,
	[Enums.anim_state.open_lighter_left] = true,
}

local CLOSE_LIGHTER_TAGS = {
	[Enums.anim_state.close_lighter] = true,
	[Enums.anim_state.close_lighter_left] = true,
}

local function shed_interact_anchor(e_shed)
	local x, y, w, h = Helper.get_collider_rect(e_shed)
	local door_center_x = x + w * 0.5
	local door_right_x = x + w
	local hand_y = y + h * 0.5
	return door_center_x, hand_y, door_right_x
end

local function tutorial_reached_x(pos_x, target_x, dir)
	if dir < 0 then
		return pos_x <= target_x
	end
	return pos_x >= target_x
end

local function open_lighter_anim_progress(e_player)
	local animation = e_player:get("animation")
	if not animation then
		return 0
	end

	local tag = animation.obj.base_tag
	if not OPEN_LIGHTER_TAGS[tag] then
		return 0
	end

	return mathx.clamp(
		(animation.obj.anim8.position - 1) / math.max(OPEN_LIGHTER_FLAME_FRAME - 1, 1),
		0,
		1
	)
end

local function close_lighter_anim_progress(e_player)
	local animation = e_player:get("animation")
	if not animation then
		return 0
	end

	local obj = animation.obj
	if not CLOSE_LIGHTER_TAGS[obj.base_tag] then
		return 0
	end

	local n = obj.anim8 and #obj.anim8.frames or 1
	return mathx.clamp((obj.anim8.position - 1) / math.max(n - 1, 1), 0, 1)
end

local function action_label(action)
	assert(Enums.input[action])
	local res = ""
	if action == Enums.input.interact then
		res = Inputs.rev_map.interact
	elseif action == Enums.input.left then
		res = Inputs.rev_map.left
	elseif action == Enums.input.right then
		res = Inputs.rev_map.right
	elseif action == Enums.input.lighter then
		res = Inputs.rev_map.lighter
	end
	return string.upper(res)
end

function Tutorial:init(world)
	self.world = world

	self.state = Settings.current.tutorial
	self.wait_kind = Enums.tutorial_wait_kind.null
	self.phase = nil
	self.shed_lighter_done = false
	self.opening_lighter_hand = false
	self.closing_lighter_hand = false

	if self.state then
		self.e_dialogue_car1 = Concord.entity(self.world)
			:give("id", "dialogue_car1")
			:give("dialogue_key", Enums.dialogue_knot.car_doors)
	end
end

function Tutorial:export_session(overrides)
	if not self.state then
		return nil
	end

	local bag = {}
	for _, field in ipairs(Data.SessionSchemas.tutorial) do
		bag[field] = self[field]
	end
	bag.active = self.state

	if overrides then
		for k, v in pairs(overrides) do
			bag[k] = v
		end
	end

	return bag
end

function Tutorial:import_session(bag)
	if not bag then
		return
	end

	for k, v in pairs(bag) do
		self[k] = v
	end

	self.state = Settings.current.tutorial and bag.active
	self.e_player = self.world:getResource("e_player")

	if self.state and not self.e_dialogue_car1 then
		self.e_dialogue_car1 = Concord.entity(self.world)
			:give("id", "dialogue_car1")
			:give("dialogue_key", Enums.dialogue_knot.car_doors)
	end
end

function Tutorial:set_beat(beat)
	assert(Enums.tutorial_beat[beat], beat)
	self.world:emit("tle_log", "beat " .. beat)
	self.beat = beat
end

function Tutorial:pause_timeline()
	if self.timeline then
		self.timeline:Pause()
	end
end

function Tutorial:resume_timeline()
	if self.timeline then
		self.timeline:Unpause()
	end
end

function Tutorial:wait_seconds(n)
	TLE.Event.Wait(n)
end

function Tutorial:wait_flux(setup)
	setup(function()
		self:resume_timeline()
	end)
	self:pause_timeline()
end

function Tutorial:wait_dialogue()
	self.waiting_dialogue = true
	self:pause_timeline()
end

function Tutorial:start_tutorial_timeline()
	if not self.state or self.timeline then
		return
	end
	self.world:emit("tle_log", "start tutorial timeline")
	self.timeline = TLE.Do(function()
		self:run_tutorial()
	end)
end

function Tutorial:kill_timeline()
	if self.timeline then
		self.timeline:Die()
		self.timeline = nil
	end
	self.wait_kind = Enums.tutorial_wait_kind.null
	self.waiting_dialogue = false
	self.waiting_hide_bars = false
end

function Tutorial:destroy_hand_key_label(duration)
	assert:type(duration, "number")
	if not self.e_hand_key_label then return end

	local e = self.e_hand_key_label
	self.e_hand_key_label = nil

	if duration and duration > 0 then
		Assemblages.HandDecal.fade_key_label(e, duration)
	else
		e:destroy()
	end
end

function Tutorial:create_hand_key_label(hand, action)
	assert(hand.__isEntity)
	assert(Enums.input[action])

	self:destroy_hand_key_label(0)

	local text = action_label(action)
	if not text then
		return
	end

	local hand_pos = hand:get("pos")
	self.e_hand_key_label = Assemblages.HandDecal.create_key_label(self.world, text, {
		id = "tutorial_hand_key_label",
		key = "tutorial_hand_key_label",
		x = hand_pos.x,
		y = hand_pos.y,
		ui_element = true,
		hand_scale = Assemblages.HandDecal.SKIP_HAND_SCALE,
	})
	local cam = self.world:getResource("camera")
	Assemblages.HandDecal.sync_key_label(hand, self.e_hand_key_label, cam)
end

function Tutorial:sync_hand_key_label()
	if self.e_last_hand and self.e_hand_key_label then
		local cam = self.world:getResource("camera")
		Assemblages.HandDecal.sync_key_label(self.e_last_hand, self.e_hand_key_label, cam)
	end
end

local function hand_trail_rotation(startx, targetx, step, count, settle_rot)
	local t = step / count
	local dx = targetx - startx
	if dx > 0 then
		local rad = (math.pi / 2) * (1 - t)
		return math.deg(rad)
	elseif dx < 0 then
		local rad = (-math.pi / 2) * (1 - t)
		return math.deg(rad)
	end
	settle_rot = settle_rot or 0
	if settle_rot == 0 then
		return 0
	end
	return math.deg(math.rad(settle_rot) * (count - step) / count)
end

function Tutorial:show_hands_trail(
	n,
	startx,
	starty,
	targetx,
	targety,
	settle_rot,
	action,
	is_instant,
	glow_opts
)
	assert:type(n, "number")
	assert:type(startx, "number")
	assert:type(starty, "number")
	assert:type(targetx, "number")
	assert:type(targety, "number")
	if settle_rot ~= nil then
		assert:type(settle_rot, "number")
	end
	assert(Enums.input[action])
	assert:type(is_instant, "boolean")
	assert:type_or_nil(glow_opts, "table")

	local glow_intensity = glow_opts and glow_opts.intensity or 0.4
	local glow_size = glow_opts and glow_opts.size or 1.5
	local glow_pulse_speed = glow_opts and glow_opts.pulse_speed or 6
	local glow_pulse_amplitude = glow_opts and glow_opts.pulse_amplitude or 0.2
	local glow_hand_light = glow_opts and glow_opts.hand_light

	local beat_id = self.beat or Enums.tutorial_beat.tutorial
	local gapx = (targetx - startx) / n
	local gapy = (targety - starty) / n
	local scale = 0.4

	for i = 1, n do
		local x = startx + gapx * i
		local y = starty + gapy * i + love.math.random(-3, 3)
		local rotation = hand_trail_rotation(startx, targetx, i, n, settle_rot)
		local blood = love.math.random(3, 9) / 10
		local dmg = love.math.random(1, 7) / 10
		local distort = love.math.random(4, 9) / 10

		if i == n then
			blood = 0
			dmg = 0
			distort = 0
		end

		local idk = beat_id .. "_hand_decal" .. i
		local e_hand = Concord.entity(self.world):assemble(
			Assemblages.HandDecal.create,
			{
				id = idk,
				key = idk,
				x = x,
				y = y,
				scale = scale,
				rotation = rotation,
				blood_amount = blood,
				damage_amount = dmg,
				distort_amount = distort,
			}
		)

		if i == n then
			self.e_last_hand = e_hand
		end

		scale = scale + love.math.random(2, 4) / 100
		scale = mathx.min(scale, 0.5)

		local target_opacity = love.math.random(6, 9) / 10
		if i == n then target_opacity = 0.9 end

		local dur = love.math.random(3, 8) / 10
		local delay = i + love.math.random(3, 7) / 10
		if is_instant then
			dur = 0
			delay = 0
		end

		Assemblages.HandDecal.fade_in(e_hand, target_opacity, dur, delay)
			:oncomplete(function()
				if i == n then
					local e_hand_pos = e_hand:get("pos")
					self.prev_hx, self.prev_hy = e_hand_pos.x, e_hand_pos.y
					local tw, th = self.world:getResource("tex_glow"):getDimensions()
					local hx, hy = e_hand_pos.x - tw * scale / 2, e_hand_pos.y - th * scale / 2
					self.e_glow = Concord.entity(self.world):assemble(
							Assemblages.BillboardGlow.create,
							hx, hy,
							9,
							glow_intensity,
							Palette.diffuse.glow_hand_decals,
							glow_size
						)
						:give("glow_pulse", glow_pulse_speed, glow_pulse_amplitude)

					if glow_hand_light then
						self.e_hand_light = Concord.entity(self.world):assemble(
							Assemblages.Light.point,
							e_hand_pos.x,
							e_hand_pos.y,
							9,
							56,
							Palette.get_diffuse("glow_hand_decals")
						)
					end

					self:create_hand_key_label(e_hand, action)
					self:resume_timeline()
				else
					Flux.to(e_hand:get("decals_shaders").data, dur * 0.9, { opacity = 0 })
						:delay(delay * 0.3)
						:oncomplete(function() e_hand:destroy() end)
				end
			end)
	end

	self:pause_timeline()
end

function Tutorial:fade_hand_and_glow(duration, on_complete)
	if self.e_last_hand then
		local last_hand_pos = self.e_last_hand:get("pos")
		self.prev_hx, self.prev_hy = last_hand_pos.x, last_hand_pos.y
		local hand = self.e_last_hand
		Assemblages.HandDecal.fade_out(hand, duration, function()
			if self.e_last_hand == hand then
				self.e_last_hand = nil
			end
			if on_complete then
				on_complete()
			end
		end)
	elseif on_complete then
		on_complete()
	end
	self:destroy_hand_key_label(duration)
	if self.e_glow then
		self.e_glow:destroy()
		self.e_glow = nil
	end
	if self.e_hand_light then
		self.e_hand_light:destroy()
		self.e_hand_light = nil
	end
end

function Tutorial:wait_hold_interact()
	self.world:emit("tle_log", "wait hold interact")
	self.hold_interact_timer = 0
	self.hit_n = 0
	self.world:emit("prepare_screen_shake")
	self.wait_kind = Enums.tutorial_wait_kind.hold_interact
	self:pause_timeline()
end

function Tutorial:wait_move_left()
	self.wait_kind = Enums.tutorial_wait_kind.move_left
	self:pause_timeline()
end

function Tutorial:wait_move_right()
	self.wait_kind = Enums.tutorial_wait_kind.move_right
	self:pause_timeline()
end

function Tutorial:wait_press_interact()
	self.wait_kind = Enums.tutorial_wait_kind.press_interact
	self:pause_timeline()
end

function Tutorial:wait_enter_shed()
	self.wait_kind = Enums.tutorial_wait_kind.enter_shed
	self:pause_timeline()
end

function Tutorial:wait_open_lighter()
	self.wait_kind = Enums.tutorial_wait_kind.open_lighter
	self:pause_timeline()
end

function Tutorial:wait_close_lighter()
	self.wait_kind = Enums.tutorial_wait_kind.close_lighter
	self:pause_timeline()
end

function Tutorial:finish_wait()
	self.wait_kind = Enums.tutorial_wait_kind.null
	self:resume_timeline()
end

function Tutorial:run_tutorial()
	self.e_player = self.world:getResource("e_player")
	assert(self.e_player ~= nil)

	-- Interact
	self:set_beat(Enums.tutorial_beat.interact)
	self.world:emit("display_bars")

	local pos = self.e_player:get("pos")
	local col = self.e_player:get("collider")
	local tx, ty = pos.x - col.w_h + 8, pos.y + col.h_h + 4
	local bx = tx - 72
	local by = ty + 8
	self:show_hands_trail(5, bx, by, tx, ty, nil, Enums.input.interact, false)
	self:wait_hold_interact()
	self.world:emit("ev_car_lights_off")

	self.world:emit("tle_log", "door open")
	self.world:emit("force_end_dialogue")
	self.world:emit("play_sound_on_player", Enums.sfx.car_door_open)
	self:wait_flux(function(resume)
		self:fade_hand_and_glow(0.3, resume)
	end)
	self.hold_interact_timer = nil
	self.e_player:remove("hidden")

	-- Move left
	self:set_beat(Enums.tutorial_beat.move_left)
	pos = self.e_player:get("pos")
	col = self.e_player:get("collider")
	tx, ty = pos.x - col.w_h - 60, pos.y + col.h_h
	bx = self.prev_hx
	by = self.prev_hy
	self:show_hands_trail(5, bx, by, tx, ty, nil, Enums.input.left, false)
	self.left_start_x = pos.x
	self.left_target_x = tx - 18
	self.e_player:give(Enums.player_cap.can_move):give(Enums.player_cap.can_move_left_only)
	self:wait_move_left()

	-- Left interact
	self:set_beat(Enums.tutorial_beat.interact_left)
	self:wait_flux(function(resume)
		self:fade_hand_and_glow(0.3, resume)
	end)
	self:wait_seconds(1)
	tx, ty = self.prev_hx, self.prev_hy
	self:show_hands_trail(5, tx, ty, tx, ty, 0, Enums.input.interact, true)
	self:wait_press_interact()

	self.world:emit(
		"start_dialogue",
		self.e_player,
		self.e_dialogue_car1,
		"car_headlights"
	)
	self:wait_dialogue()

	-- Move right
	self:set_beat(Enums.tutorial_beat.move_right)
	local startx, starty = self.prev_hx, self.prev_hy
	pos = self.e_player:get("pos")
	col = self.e_player:get("collider")
	tx, ty = pos.x - col.w_h + 144, pos.y + col.h_h + 4
	self:show_hands_trail(8, startx, starty, tx, ty, nil, Enums.input.right, false)
	self.right_start_x = pos.x
	self.right_target_x = tx + 7
	self.e_player:give(Enums.player_cap.can_move)
		:remove(Enums.player_cap.can_move_left_only)
		:give(Enums.player_cap.can_move_right_only)
	self:wait_move_right()

	-- Right interact + trunk
	self:set_beat(Enums.tutorial_beat.interact_right)
	self.world:emit("player_force_face_dir", -1)
	self:wait_flux(function(resume)
		self:fade_hand_and_glow(0.3, resume)
	end)
	self:wait_seconds(1)
	tx, ty = self.prev_hx, self.prev_hy
	self:show_hands_trail(5, tx, ty, tx, ty, 0, Enums.input.interact, true)
	self.world:emit("player_force_face_dir", -1)
	self:wait_press_interact()

	self.world:emit("player_force_face_dir", -1)
	Log.debug("TODO: open the trunk animation?")
	self.world:emit("play_sound_on_player", Enums.sfx.trunk_open)
	self:wait_seconds(1)
	self.world:emit(
		"start_dialogue",
		self.e_player,
		self.e_dialogue_car1,
		"car_trunk"
	)
	self:wait_dialogue()

	-- Explore
	self:set_beat(Enums.tutorial_beat.explore)
	local cam = self.world:getResource("camera")
	local dt_cam = {}
	dt_cam.scale = cam:getScale()
	self.waiting_hide_bars = true
	Flux.to(dt_cam, 6, { scale = dt_cam.scale * 0.7 })
		:onupdate(function()
			self.world:emit("set_camera_transform", cam, {
				scale = dt_cam.scale,
			})
		end)
		:oncomplete(function()
			self.world:emit("hide_bars")
		end)
	self:pause_timeline()

	self:set_beat(Enums.tutorial_beat.reach_shed)
	pos = self.e_player:get("pos")
	self.reach_shed_start_x = pos.x
	self.shed_hand_shown = false
	self.e_shed = self.world:getEntityByKey("shed")
	assert(self.e_shed)
	local _, _, shed_hand_trigger_x = shed_interact_anchor(self.e_shed)
	self.shed_hand_trigger_x = shed_hand_trigger_x
	self.wait_kind = Enums.tutorial_wait_kind.reach_shed
	self.e_player:give(Enums.player_cap.can_move)
		:give(Enums.player_cap.can_interact)
		:remove(Enums.player_cap.can_move_left_only)
		:remove(Enums.player_cap.can_move_right_only)
	self.world:emit("camera_follow", self.e_player, 0.25)
	self:pause_timeline()

	self.e_frontdoor = self.world:getEntityByKey("frontdoor")
	assert(self.e_shed ~= nil and self.e_frontdoor ~= nil)
	tx, ty = shed_interact_anchor(self.e_shed)
	self:show_hands_trail(5, tx, ty, tx, ty, 90, Enums.input.interact, true)
	if self.e_shed:has("is_door") then
		self.e_shed:remove("is_door")
	end
	self.e_shed:give("is_door_ev", "ev_tutorial_enter_shed")
	self:wait_enter_shed()
end

function Tutorial:begin_shed_open_lighter(e_player)
	self.e_player = e_player
	self.phase = "shed"
	self:set_beat(Enums.tutorial_beat.open_lighter)
	self.world:emit("toggle_component", e_player, Enums.player_cap.can_move, false)
	self.world:emit("toggle_component", e_player, Enums.player_cap.can_interact, false)

	if not self.e_dialogue_shed then
		self.e_dialogue_shed = Concord.entity(self.world)
			:give("id", "dialogue_shed")
			:give("dialogue_key", "shed_interior")
	end

	self.timeline = TLE.Do(function()
		self:wait_seconds(2)
		self.world:emit("start_dialogue", self.e_player, self.e_dialogue_shed, "shed_interior")
		self:wait_dialogue()
		self:prompt_shed_open_lighter()

		self:wait_seconds(1)
		self.world:emit("start_dialogue", self.e_player, self.e_dialogue_shed, "shed_interior_lit")
		self:wait_dialogue()
		self:prompt_shed_close_lighter()

		self:complete_shed_open_lighter()
	end)
end

function Tutorial:prompt_shed_hand_lighter(action, glow_opts)
	self.world:emit("toggle_component", self.e_player, Enums.player_cap.can_lighter, true)

	local pos = self.e_player:get("pos")
	local col = self.e_player:get("collider")
	local tx, ty = pos.x - col.w_h + 8, pos.y + 12
	self:show_hands_trail(5, tx, ty, tx, ty, 0, action, true, glow_opts)
end

function Tutorial:prompt_shed_open_lighter()
	self:prompt_shed_hand_lighter(Enums.input.lighter, {
		intensity = 1.2,
		size = 3.5,
		pulse_speed = 5,
		pulse_amplitude = 0.35,
		hand_light = true,
	})
	self:wait_open_lighter()
end

function Tutorial:prompt_shed_close_lighter()
	self:set_beat(Enums.tutorial_beat.close_lighter)
	self.e_player:remove("block_lighter_close")
	self:prompt_shed_hand_lighter(Enums.input.lighter, {
		intensity = 1.2,
		size = 3.5,
		pulse_speed = 5,
		pulse_amplitude = 0.35,
		hand_light = true,
	})
	self:wait_close_lighter()
end

function Tutorial:complete_shed_open_lighter()
	self.shed_lighter_done = true
	self.phase = "outside_resume"
	self.e_player:remove("block_lighter_close")
	self.world:emit("toggle_component", self.e_player, Enums.player_cap.can_move, true)
	self.world:emit("toggle_component", self.e_player, Enums.player_cap.can_interact, true)
end

function Tutorial:resume_outside_after_shed(e_player)
	self.e_player = e_player
	self.e_frontdoor = self.world:getEntityByKey("frontdoor")
	self.e_shed = self.world:getEntityByKey("shed")
	self.world:emit("open_shed_door")

	self.timeline = TLE.Do(function()
		self:set_beat(Enums.tutorial_beat.outside_frontdoor)
		self.world:emit("play_sound_on_entity", self.e_frontdoor, Enums.sfx.house_scream)
		self.world:emit("player_force_face_dir", 1)
		self:wait_seconds(1)
		self.world:emit("start_dialogue", self.e_player, self.e_shed, "shed2")
		self:wait_dialogue()
		self:set_beat(Enums.tutorial_beat.done)
		Save.set_flag("outside_intro_done", true, true)
		self.world:emit("open_backdoor")
		self.world:emit("tle_log", "tutorial timeline done")
		self:kill_timeline()
	end)
end

function Tutorial:sync_player_bump(e)
	local bump_sys = self.world:getSystem(ECS.get_system_class("bump_collision"))
	bump_sys.pool:update(e)
end

function Tutorial:complete_move_left()
	local e = self.e_player
	e:get("pos").x = self.left_target_x
	self:sync_player_bump(e)
	e:remove(Enums.player_cap.can_move):remove(Enums.player_cap.can_move_left_only)
	self.world:__flush()
	self.world:emit("player_stop")
	self.world:emit("player_force_face_dir", 1)
	self:finish_wait()
end

function Tutorial:complete_move_right()
	local e = self.e_player
	e:get("pos").x = self.right_target_x
	self:sync_player_bump(e)
	e:remove(Enums.player_cap.can_move):remove(Enums.player_cap.can_move_right_only)
	self.world:__flush()
	self.world:emit("player_stop")
	self.world:emit("player_force_face_dir", -1)
	self:finish_wait()
end

function Tutorial:update(dt)
	if not self.state then return end
	assert(Enums.tutorial_wait_kind[self.wait_kind])

	if self.wait_kind == Enums.tutorial_wait_kind.move_left then
		local player_pos = self.e_player:get("pos")
		local progress = (self.left_start_x - player_pos.x) / (self.left_start_x - self.left_target_x)
		progress = mathx.clamp(progress, 0, 1)
		Assemblages.HandDecal.set_progress(self.e_last_hand, progress, 0.9, self.e_hand_key_label)

		if tutorial_reached_x(player_pos.x, self.left_target_x, -1) then
			self:complete_move_left()
		end
	elseif self.wait_kind == Enums.tutorial_wait_kind.move_right then
		local player_pos = self.e_player:get("pos")
		local progress = (self.right_start_x - player_pos.x) / (self.right_start_x - self.right_target_x)
		progress = mathx.clamp(progress, 0, 1)
		Assemblages.HandDecal.set_progress(self.e_last_hand, progress, 0.9, self.e_hand_key_label)

		if tutorial_reached_x(player_pos.x, self.right_target_x, 1) then
			self:complete_move_right()
		end
	elseif self.wait_kind == Enums.tutorial_wait_kind.reach_shed then
		local player_pos = self.e_player:get("pos")
		if not self.shed_hand_shown
			and tutorial_reached_x(player_pos.x, self.shed_hand_trigger_x, -1) then
			self.shed_hand_shown = true
			self:finish_wait()
		end
	end
end

function Tutorial:state_update(dt)
	if not self.state then return end

	self:sync_hand_key_label()

	if self.opening_lighter_hand and self.e_player then
		local progress = open_lighter_anim_progress(self.e_player)
		Assemblages.HandDecal.set_progress(
			self.e_last_hand,
			progress,
			0.9,
			self.e_hand_key_label,
			PRESS_HAND_PROGRESS_OPTS
		)
		if progress >= 1 then
			self:finish_opening_lighter_hand()
		end
	elseif self.closing_lighter_hand and self.e_player then
		local progress = close_lighter_anim_progress(self.e_player)
		Assemblages.HandDecal.set_progress(
			self.e_last_hand,
			progress,
			0.9,
			self.e_hand_key_label,
			PRESS_HAND_PROGRESS_OPTS
		)
	end

	if self.wait_kind == Enums.tutorial_wait_kind.hold_interact then
		if Inputs.pressed(Enums.input.interact) or Inputs.down(Enums.input.interact) then
			self.hold_interact_timer = self.hold_interact_timer + dt * 0.3
		end

		self.hold_interact_timer = mathx.clamp(self.hold_interact_timer, 0, MAX_HOLD_INTERACT_TIMER)

		local progress = mathx.clamp(self.hold_interact_timer, 0, 1)
		Assemblages.HandDecal.set_progress(self.e_last_hand, progress, 0.9, self.e_hand_key_label)

		if self.hit_n == 0 and progress >= 0.1 then
			self.hit_n = 1
			self.world:emit("play_sound_on_player", Enums.sfx.car_door_hit)
			self.world:emit("screen_shake", 0.1, 0.08)
			self.world:emit(
				"start_dialogue",
				self.e_player,
				self.e_dialogue_car1,
				Enums.dialogue_knot.car_doors
			)
		elseif self.hit_n == 1 and progress >= 0.25 then
			self.hit_n = 2
			self.world:emit("play_sound_on_player", Enums.sfx.car_door_hit)
			self.world:emit("screen_shake", 0.15, 0.12)
		elseif self.hit_n == 2 and progress >= 0.5 then
			self.hit_n = 3
			self.world:emit("play_sound_on_player", Enums.sfx.car_door_hit)
			self.world:emit("screen_shake", 0.2, 0.16)
			self.world:emit(
				"start_dialogue",
				self.e_player,
				self.e_dialogue_car1,
				"car_doors2"
			)
		elseif self.hit_n == 3 and progress >= 0.75 then
			self.hit_n = 4
			self.world:emit("play_sound_on_player", Enums.sfx.car_door_hit)
			self.world:emit("screen_shake", 0.3, 0.24)
			self.world:emit(
				"start_dialogue",
				self.e_player,
				self.e_dialogue_car1,
				"car_doors3"
			)
		end

		if progress >= 1 then
			self.world:emit("finalize_screen_shake", true)
			self:finish_wait()
		end
	elseif self.wait_kind == Enums.tutorial_wait_kind.press_interact then
		if Inputs.pressed(Enums.input.interact) then
			self.wait_kind = Enums.tutorial_wait_kind.null
			local progress = { value = 0 }
			Flux.to(progress, 2, { value = 1 }):onupdate(function()
				Assemblages.HandDecal.set_progress(
					self.e_last_hand,
					progress.value,
					0.9,
					self.e_hand_key_label,
					PRESS_HAND_PROGRESS_OPTS
				)
			end):oncomplete(function()
				self:fade_hand_and_glow(0.3, function()
					self:resume_timeline()
				end)
			end)
		end
	elseif self.wait_kind == Enums.tutorial_wait_kind.open_lighter then
		if Inputs.pressed(Enums.input.lighter) then
			self.wait_kind = Enums.tutorial_wait_kind.null
			self.e_player:give("block_lighter_close")
			self.opening_lighter_hand = true
		end
	elseif self.wait_kind == Enums.tutorial_wait_kind.close_lighter then
		if Inputs.pressed(Enums.input.lighter) then
			local player_controller = self.world:getSystem(ECS.get_system_class("player_controller"))
			if not player_controller.on_lighter then
				return
			end
			self.wait_kind = Enums.tutorial_wait_kind.null
			self.closing_lighter_hand = true
		end
	end
end

function Tutorial:state_draw_ex()
	if not self.state then return end
	if DEV and self.beat then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.print("IN TUTORIAL: " .. self.beat, 0, 38)
	end
end

function Tutorial:ev_tutorial_enter_shed(e_player, e_shed)
	assert(e_player.__isEntity and e_player:has("player"), e_player)
	assert(e_shed.__isEntity, e_shed)
	if self.wait_kind ~= Enums.tutorial_wait_kind.enter_shed then
		return
	end

	self.wait_kind = Enums.tutorial_wait_kind.null
	self.phase = "shed"
	self:fade_hand_and_glow(0.3)
	self.world:emit("toggle_component", e_player, Enums.player_cap.can_move, false)
	self.world:emit("toggle_component", e_player, Enums.player_cap.can_interact, false)
	self.world:emit("anim_open_door", e_player)
	self.world:emit("switch_state", Enums.game_state.Shed, 1.5, 0.5)
end

function Tutorial:finish_opening_lighter_hand()
	if not self.opening_lighter_hand then
		return
	end

	self.opening_lighter_hand = false
	Assemblages.HandDecal.set_progress(
		self.e_last_hand,
		1,
		0.9,
		self.e_hand_key_label,
		PRESS_HAND_PROGRESS_OPTS
	)
	self:fade_hand_and_glow(0, function()
		self:resume_timeline()
	end)
end

function Tutorial:on_anim_close_lighter_done()
	if not self.closing_lighter_hand then
		return
	end

	self.closing_lighter_hand = false
	Assemblages.HandDecal.set_progress(
		self.e_last_hand,
		1,
		0.9,
		self.e_hand_key_label,
		PRESS_HAND_PROGRESS_OPTS
	)
	self:fade_hand_and_glow(0, function()
		self:resume_timeline()
	end)
end

function Tutorial:ev_dialogue_fin()
	if not self.waiting_dialogue then return end
	self.waiting_dialogue = false
	self:resume_timeline()
end

function Tutorial:ev_on_hide_bars_complete()
	if not self.waiting_hide_bars then return end
	self.waiting_hide_bars = false
	self.world:emit("toggle_component", self.e_player, Enums.player_cap.can_move, true)
	self.world:emit("toggle_component", self.e_player, Enums.player_cap.can_interact, true)
	self.world:emit("toggle_component", self.e_player, Enums.player_cap.can_run, false)
	self:resume_timeline()
end

function Tutorial:cleanup()
	if self.state and self.beat and self.beat ~= Enums.tutorial_beat.done and self.phase then
		local bag = self:export_session()
		if bag then
			Session.put("tutorial", bag)
		end
	end
	self:kill_timeline()
end

return Tutorial
