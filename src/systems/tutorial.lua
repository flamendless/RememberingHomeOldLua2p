local Tutorial = Concord.system({})

local MAX_HOLD_INTERACT_TIMER = 3

local function tutorial_reached_x(pos_x, target_x, dir)
	if dir < 0 then
		return pos_x <= target_x
	end
	return pos_x >= target_x
end

local function action_label(action)
	assert:type(action, "string")
	if action == "interact" then
		return string.upper(Inputs.rev_map.interact)
	elseif action == "left" then
		return string.upper(Inputs.rev_map.left)
	elseif action == "right" then
		return string.upper(Inputs.rev_map.right)
	elseif action == "lighter" then
		return string.upper(Inputs.rev_map.lighter)
	end
end

function Tutorial:init(world)
	self.world = world

	self.state = Settings.current.tutorial
	self.wait_kind = Enums.tutorial_wait_kind.null

	if self.state then
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

function Tutorial:start_timeline()
	self.world:emit("tle_log", "tutorial timeline begin")
	self.timeline = TLE.Do(function()
		self:run_tutorial()
	end)
end

function Tutorial:start_tutorial_timeline()
	if not self.state or self.timeline then
		return
	end
	self.world:emit("tle_log", "start tutorial timeline")
	self:start_timeline()
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
	assert:type(action, "string")

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

function Tutorial:show_hands_trail(
	n,
	startx,
	starty,
	targetx,
	targety,
	startrot,
	action,
	is_instant
)
	assert:type(n, "number")
	assert:type(startx, "number")
	assert:type(starty, "number")
	assert:type(targetx, "number")
	assert:type(targety, "number")
	assert:type(startrot, "number")
	assert(Enums.input[action])
	assert:type(is_instant, "boolean")

	local beat_id = self.beat or Enums.tutorial_beat.tutorial
	local gapx = (targetx - startx) / n
	local gapy = (targety - starty) / n
	local r = ((0 - startrot + 180) % 360) - 180
	local scale = 0.4

	for i = 1, n do
		local x = startx + gapx * i
		local y = starty + gapy * i + love.math.random(-3, 3)
		local blood = love.math.random(3, 9) / 10
		local dmg = love.math.random(1, 7) / 10
		local distort = love.math.random(4, 9) / 10

		if i == n then
			r = 0
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
				rotation = r,
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
		r = r - love.math.random(15, 30)

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
							0.4,
							Palette.diffuse.glow_hand_decals,
							1.5
						)
						:give("glow_pulse", 6, 0.2)

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

function Tutorial:wait_lighter_press()
	self.wait_kind = Enums.tutorial_wait_kind.lighter
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
	self:show_hands_trail(5, bx, by, tx, ty, 90, Enums.input.interact, false)
	self:wait_hold_interact()

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
	self:show_hands_trail(5, bx, by, tx, ty, 270, Enums.input.left, false)
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
	self:show_hands_trail(8, startx, starty, tx, ty, 0, Enums.input.right, false)
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
		"car_trunk_pre"
	)
	self:wait_dialogue()

	-- Lighter
	self:set_beat(Enums.tutorial_beat.lighter)
	tx, ty = self.prev_hx, self.prev_hy
	self:show_hands_trail(5, tx, ty, tx, ty, 0, Enums.input.lighter, true)
	self:wait_lighter_press()

	Log.debug("TODO: show lighter / play animation")
	self:wait_seconds(1)
	self.world:emit(
		"start_dialogue",
		self.e_player,
		self.e_dialogue_car1,
		"car_trunk"
	)
	self:wait_dialogue()
	self.e_player:remove("block_lighter_close")
	self.world:emit("on_close_lighter")

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

	self:set_beat(Enums.tutorial_beat.done)
	self.world:emit("tle_log", "tutorial timeline done")
	self:kill_timeline()
end

function Tutorial:sync_player_bump(e)
	local bump_sys = self.world:getSystem(ECS.get_system_class("bump_collision"))
	local pos = e:get("pos")
	local col = e:get("collider")
	bump_sys.pool:update(e, pos.x, pos.y, col.w, col.h)
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

function Tutorial:update_movement(dt)
	assert(Enums.tutorial_wait_kind[self.wait_kind])
	if self.wait_kind == Enums.tutorial_wait_kind.move_left then
		local current = self.e_player:get("pos").x
		local progress = (self.left_start_x - current) / (self.left_start_x - self.left_target_x)
		progress = mathx.clamp(progress, 0, 1)
		Assemblages.HandDecal.set_progress(self.e_last_hand, progress, 0.9, self.e_hand_key_label)

		if tutorial_reached_x(current, self.left_target_x, -1) then
			self:complete_move_left()
		end

	elseif self.wait_kind == Enums.tutorial_wait_kind.move_right then
		local current = self.e_player:get("pos").x
		local progress = (self.right_start_x - current) / (self.right_start_x - self.right_target_x)
		progress = mathx.clamp(progress, 0, 1)
		Assemblages.HandDecal.set_progress(self.e_last_hand, progress, 0.9, self.e_hand_key_label)

		if tutorial_reached_x(current, self.right_target_x, 1) then
			self:complete_move_right()
		end
	end
end

function Tutorial:update(dt)
	if not self.state then
		return
	end
	self:update_movement(dt)
end

function Tutorial:state_update(dt)
	if not self.state then return end

	self:sync_hand_key_label()

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
				Assemblages.HandDecal.set_progress(self.e_last_hand, progress.value, 0.9, self.e_hand_key_label)
			end):oncomplete(function()
				self:fade_hand_and_glow(0.3, function()
					self:resume_timeline()
				end)
			end)
		end

	elseif self.wait_kind == Enums.tutorial_wait_kind.lighter then
		if Inputs.pressed(Enums.input.lighter) then
			self.wait_kind = Enums.tutorial_wait_kind.null
			self.e_player:give("block_lighter_close")
			self.world:emit("on_open_lighter")
			Log.debug("TODO: instead of fading out, the decal should like explode/burn quickly because of the light?")
			local progress = { value = 0 }
			Flux.to(progress, 1, { value = 1 }):onupdate(function()
				Assemblages.HandDecal.set_progress(self.e_last_hand, progress.value, 0.9, self.e_hand_key_label)
			end):oncomplete(function()
				self:fade_hand_and_glow(0.3, function()
					self:resume_timeline()
				end)
			end):ease("backinout")
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

function Tutorial:ev_dialogue_fin()
	if not self.waiting_dialogue then
		return
	end
	self.waiting_dialogue = false
	self:resume_timeline()
end

function Tutorial:ev_on_hide_bars_complete()
	if not self.waiting_hide_bars then
		return
	end
	self.waiting_hide_bars = false
	self.world:emit("toggle_component", self.e_player, Enums.player_cap.can_move, true)
	self.world:emit("toggle_component", self.e_player, Enums.player_cap.can_interact, true)
	self.world:emit("toggle_component", self.e_player, Enums.player_cap.can_run, false)
	self:resume_timeline()
end

function Tutorial:cleanup()
	self:kill_timeline()
end

return Tutorial
