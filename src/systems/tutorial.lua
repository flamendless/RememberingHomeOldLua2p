local Tutorial = Concord.system({})

local MAX_HOLD_INTERACT_TIMER = 3

local STEP_ACTION = {
	[Enums.tutorial_step.waiting_interact] = "interact",
	[Enums.tutorial_step.waiting_left] = "left",
	[Enums.tutorial_step.waiting_right] = "right",
	[Enums.tutorial_step.waiting_left_interact] = "interact",
	[Enums.tutorial_step.waiting_right_interact] = "interact",
	[Enums.tutorial_step.wait_lighter_trigger] = "lighter",
}

local function tutorial_reached_x(pos_x, target_x, dir)
	if dir < 0 then
		return pos_x <= target_x
	end
	return pos_x >= target_x
end

local function action_label(action)
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

	if self.state then
		self.e_dialogue_car1 = Concord.entity(self.world)
			:give("id", "dialogue_car1")
			:give("dialogue_key", "car_doors")
	end

	self.step = Enums.tutorial_step.waiting
end

function Tutorial:destroy_hand_key_label(duration)
	if not self.e_hand_key_label then
		return
	end

	local e = self.e_hand_key_label
	self.e_hand_key_label = nil

	if duration and duration > 0 then
		Assemblages.HandDecal.fade_key_label(e, duration)
	else
		e:destroy()
	end
end

function Tutorial:create_hand_key_label(hand, next_step)
	self:destroy_hand_key_label(0)

	local action = STEP_ACTION[next_step]
	if not action then
		return
	end

	local text = action_label(action)
	if not text then
		return
	end

	self.e_hand_key_label = Assemblages.HandDecal.create_key_label(self.world, text, {
		id = "tutorial_hand_key_label",
		key = "tutorial_hand_key_label",
		x = hand.pos.x,
		y = hand.pos.y,
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
	next_step,
	is_instant
)
	Log.debug(
		"show_handsl_trail",
		n,
		startx,
		starty,
		targetx,
		targety,
		startrot,
		next_step,
		is_instant
	)
	assert(Enums.tutorial_step[next_step])

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

		local e_hand = Concord.entity(self.world):assemble(
			Assemblages.HandDecal.create,
			{
				id = self.step .. "_hand_decal" .. i,
				key = self.step .. "_hand_decal" .. i,
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
					self.prev_hx, self.prev_hy = e_hand.pos.x, e_hand.pos.y
					local tw, th = self.world:getResource("tex_glow"):getDimensions()
					local hx, hy = e_hand.pos.x - tw * scale / 2, e_hand.pos.y - th * scale / 2
					self.e_glow = Concord.entity(self.world):assemble(
							Assemblages.BillboardGlow.create,
							hx, hy,
							9,
							0.4,
							Palette.diffuse.glow_hand_decals,
							1.5
						)
						:give("glow_pulse", 6, 0.2)

					self:create_hand_key_label(e_hand, next_step)
					self:tutorial_step_set(next_step)

				else
					Flux.to(e_hand.decals_shaders.data, dur * 0.9, { opacity = 0 })
						:delay(delay * 0.3)
						:oncomplete(function() e_hand:destroy() end)
				end
			end)
	end
end

function Tutorial:fade_hand_and_glow(duration, on_complete)
	if self.e_last_hand then
		self.prev_hx, self.prev_hy = self.e_last_hand.pos.x, self.e_last_hand.pos.y
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

function Tutorial:tutorial_step_set(step)
	assert(Enums.tutorial_step[step], step)
	Log.info("Tutorial step", "from:", self.step, "to:", step)
	self.step = step

	if self.step == Enums.tutorial_step.interact then
		self.world:emit("display_bars")
		self.e_player = self.world:getResource("e_player")
		assert(self.e_player ~= nil)

		local pos = self.e_player.pos
		local col = self.e_player.collider
		local tx, ty = pos.x - col.w_h + 8, pos.y + col.h_h + 4
		local bx = tx - 72
		local by = ty + 8
		self:show_hands_trail(5, bx, by, tx, ty, 90, Enums.tutorial_step.waiting_interact, false)

	elseif self.step == Enums.tutorial_step.waiting_interact then
		self.hold_interact_timer = 0
		self.hit_n = 0

	elseif self.step == Enums.tutorial_step.done_waiting_interact then
		self.world:emit("force_end_dialogue")
		self.world:emit("play_sound_on_player", Enums.sfx.car_door_open)
		self:fade_hand_and_glow(0.3)
		self.hold_interact_timer = nil
		self.e_player:remove("hidden")
		self:tutorial_step_set(Enums.tutorial_step.show_left)

	elseif self.step == Enums.tutorial_step.show_left then
		local pos = self.e_player.pos
		local col = self.e_player.collider
		local tx, ty = pos.x - col.w_h - 60, pos.y + col.h_h
		local bx = self.prev_hx
		local by = self.prev_hy
		self:show_hands_trail(5, bx, by, tx, ty, 270, Enums.tutorial_step.waiting_left, false)
		self.left_start_x = self.e_player.pos.x
		self.left_target_x = tx - 18

	elseif self.step == Enums.tutorial_step.waiting_left then
		self.e_player:give("can_move"):give("can_move_left_only")

	elseif self.step == Enums.tutorial_step.show_left_interact then
		local tx, ty = self.e_last_hand.pos.x, self.e_last_hand.pos.y
		self:fade_hand_and_glow(0.3)

		GameStates.after(1, function ()
			self:show_hands_trail(
				5,
				tx, ty,
				tx, ty,
				0,
				Enums.tutorial_step.waiting_left_interact,
				true
			)
		end)

	elseif self.step == Enums.tutorial_step.waiting_left_interact then
		self.is_fluxing = false

	elseif self.step == Enums.tutorial_step.done_left_interact then
		self.world:emit(
			"start_dialogue",
			self.e_player,
			self.e_dialogue_car1,
			"car_headlights"
		)

	elseif self.step == Enums.tutorial_step.show_right then
		local startx, starty = self.prev_hx, self.prev_hy

		local pos = self.e_player.pos
		local col = self.e_player.collider
		local tx, ty = pos.x - col.w_h + 144, pos.y + col.h_h + 4
		self:show_hands_trail(
			8,
			startx, starty,
			tx, ty,
			0,
			Enums.tutorial_step.waiting_right,
			false
		)

		self.right_start_x = self.e_player.pos.x
		self.right_target_x = tx + 7

	elseif self.step == Enums.tutorial_step.waiting_right then
		self.e_player:give("can_move"):remove("can_move_left_only"):give("can_move_right_only")

	elseif self.step == Enums.tutorial_step.show_right_interact then
		self.world:emit("player_force_face_dir", -1)

		local tx, ty = self.e_last_hand.pos.x, self.e_last_hand.pos.y
		self:fade_hand_and_glow(0.3)

		GameStates.after(1, function ()
			self:show_hands_trail(
				5,
				tx, ty,
				tx, ty,
				0,
				Enums.tutorial_step.waiting_right_interact,
				true
			)
		end)

	elseif self.step == Enums.tutorial_step.waiting_right_interact then
		self.world:emit("player_force_face_dir", -1)
		self.is_fluxing = false

	elseif self.step == Enums.tutorial_step.done_right_interact then
		self.world:emit("player_force_face_dir", -1)
		-- TODO: open the trunk animation?
		Log.debug("TODO: open the trunk animation?")
		self.world:emit("play_sound_on_player", Enums.sfx.trunk_open)
		GameStates.after(1, function()
			self.world:emit(
				"start_dialogue",
				self.e_player,
				self.e_dialogue_car1,
				"car_trunk_pre"
			)
		end)

	elseif self.step == Enums.tutorial_step.show_lighter then
		local tx, ty = self.prev_hx, self.prev_hy
		self:show_hands_trail(
			5,
			tx, ty,
			tx, ty,
			0,
			Enums.tutorial_step.wait_lighter_trigger,
			true
		)

	elseif self.step == Enums.tutorial_step.wait_lighter_trigger then
		self.triggered_lighter = false

	elseif self.step == Enums.tutorial_step.done_lighter_trigger then
		-- TODO: show lighter / play animation
		Log.debug("TODO: show lighter / play animation")
		GameStates.after(1, function()
			self.world:emit(
				"start_dialogue",
				self.e_player,
				self.e_dialogue_car1,
				"car_trunk"
			)
		end)

	elseif self.step == Enums.tutorial_step.explore then
		local cam = self.world:getResource("camera")
		local dt_cam = {}
		dt_cam.scale = cam:getScale()
		Flux.to(dt_cam, 6, { scale = dt_cam.scale * 0.7 })
			:onupdate(function()
				self.world:emit("set_camera_transform", cam, {
					scale = dt_cam.scale,
				})
			end)
			:oncomplete(function()
				self.world:emit("hide_bars")
			end)

	elseif self.step == Enums.tutorial_step.run then
		print("111")

	else
		error("unimplemented " .. self.step)
	end
end

function Tutorial:sync_player_bump(e)
	local bump_sys = self.world:getSystem(ECS.get_system_class("bump_collision"))
	local col = e.collider
	bump_sys.pool:update(e, e.pos.x, e.pos.y, col.w, col.h)
end

function Tutorial:complete_move_left()
	local e = self.e_player
	e.pos.x = self.left_target_x
	self:sync_player_bump(e)
	e:remove("can_move"):remove("can_move_left_only")
	self.world:__flush()
	self.world:emit("player_stop")
	self.world:emit("player_force_face_dir", 1)
	self:tutorial_step_set(Enums.tutorial_step.show_left_interact)
end

function Tutorial:complete_move_right()
	local e = self.e_player
	e.pos.x = self.right_target_x
	self:sync_player_bump(e)
	e:remove("can_move"):remove("can_move_right_only")
	self.world:__flush()
	self.world:emit("player_stop")
	self.world:emit("player_force_face_dir", -1)
	self:tutorial_step_set(Enums.tutorial_step.show_right_interact)
end

function Tutorial:update_movement(dt)
	if self.step == Enums.tutorial_step.waiting_left then
		local current = self.e_player.pos.x
		local progress = (self.left_start_x - current) / (self.left_start_x - self.left_target_x)
		progress = mathx.clamp(progress, 0, 1)
		Assemblages.HandDecal.set_progress(self.e_last_hand, progress, 0.9, self.e_hand_key_label)

		if tutorial_reached_x(current, self.left_target_x, -1) then
			self:complete_move_left()
		end

	elseif self.step == Enums.tutorial_step.waiting_right then
		local current = self.e_player.pos.x
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

	if self.step == Enums.tutorial_step.waiting_interact then
		if Inputs.pressed("interact") or Inputs.down("interact") then
			self.hold_interact_timer = self.hold_interact_timer + dt * 0.3
		end

		self.hold_interact_timer = mathx.clamp(self.hold_interact_timer, 0, MAX_HOLD_INTERACT_TIMER)

		local progress = mathx.clamp(self.hold_interact_timer, 0, 1)
		Assemblages.HandDecal.set_progress(self.e_last_hand, progress, 0.9, self.e_hand_key_label)

		if self.hit_n == 0 and progress >= 0.1 and progress <= 0.25 then
			self.world:emit("play_sound_on_player", Enums.sfx.car_door_hit)
			self.world:emit("prepare_screen_shake")
			self.hit_n = 1
			self.world:emit("screen_shake", 0.1, 0.005)
			self.world:emit(
				"start_dialogue",
				self.e_player,
				self.e_dialogue_car1,
				"car_doors"
			)
		elseif self.hit_n == 1 and progress > 0.25 and progress <= 0.5 then
			self.hit_n = 2
			self.world:emit("play_sound_on_player", Enums.sfx.car_door_hit)
			self.world:emit("screen_shake", 0.15, 0.01)
		elseif self.hit_n == 2 and progress > 0.5 and progress <= 0.75 then
			self.hit_n = 3
			self.world:emit("play_sound_on_player", Enums.sfx.car_door_hit)
			self.world:emit("screen_shake", 0.2, 0.015)
			self.world:emit(
				"start_dialogue",
				self.e_player,
				self.e_dialogue_car1,
				"car_doors2"
			)
		elseif self.hit_n == 3 and progress > 0.75 and progress <= 0.99 then
			self.hit_n = 4
			self.world:emit("play_sound_on_player", Enums.sfx.car_door_hit)
			self.world:emit("screen_shake", 0.3, 0.03)
			self.world:emit(
				"start_dialogue",
				self.e_player,
				self.e_dialogue_car1,
				"car_doors3"
			)
		end

		if progress >= 1 then
			self.world:emit("finalize_screen_shake", true)
			self:tutorial_step_set(Enums.tutorial_step.done_waiting_interact)
		end

	elseif self.step == Enums.tutorial_step.waiting_left_interact and not self.is_fluxing then
		if Inputs.pressed("interact") then
			self.is_fluxing = true
			local progress = {value = 0}
			Flux.to(progress, 2, { value = 1 }):onupdate(function()
				Assemblages.HandDecal.set_progress(self.e_last_hand, progress.value, 0.9, self.e_hand_key_label)
			end):oncomplete(function()
				self:fade_hand_and_glow(0.3, function()
					self:tutorial_step_set(Enums.tutorial_step.done_left_interact)
				end)
			end)
		end

	elseif self.step == Enums.tutorial_step.waiting_right_interact and not self.is_fluxing then
		if Inputs.pressed("interact") then
			self.is_fluxing = true
			local progress = {value = 0}
			Flux.to(progress, 2, { value = 1 }):onupdate(function()
				Assemblages.HandDecal.set_progress(self.e_last_hand, progress.value, 0.9, self.e_hand_key_label)
			end):oncomplete(function()
				self:fade_hand_and_glow(0.3, function()
					self:tutorial_step_set(Enums.tutorial_step.done_right_interact)
				end)
			end)
		end

	elseif self.step == Enums.tutorial_step.wait_lighter_trigger and not self.triggered_lighter then
		if Inputs.pressed("lighter") then
			self.triggered_lighter = true
			self.e_player:give("block_lighter_close")
			self.world:emit("on_open_lighter")
			--TODO: instead of fading out, the decal should like explode/burn quickly because of the light?
			Log.debug("TODO: instead of fading out, the decal should like explode/burn quickly because of the light?")
			local progress = {value = 0}
			Flux.to(progress, 1, { value = 1 }):onupdate(function()
				Assemblages.HandDecal.set_progress(self.e_last_hand, progress.value, 0.9, self.e_hand_key_label)
			end):oncomplete(function()
				self:fade_hand_and_glow(0.3, function()
					self:tutorial_step_set(Enums.tutorial_step.done_lighter_trigger)
				end)
			end):ease("backinout")
		end
	end
end

function Tutorial:state_draw_ex()
	if not self.state then return end
	if DEV then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.print("IN TUTORIAL: " .. self.step, 0, 38)
	end
end

function Tutorial:ev_dialogue_fin()
	if self.step == Enums.tutorial_step.done_left_interact then
		self:tutorial_step_set(Enums.tutorial_step.show_right)
	elseif self.step == Enums.tutorial_step.done_right_interact then
		self:tutorial_step_set(Enums.tutorial_step.show_lighter)
	elseif self.step == Enums.tutorial_step.done_lighter_trigger then
		self.e_player:remove("block_lighter_close")
		self.world:emit("on_close_lighter")
		self:tutorial_step_set(Enums.tutorial_step.explore)
	end
end

function Tutorial:ev_on_hide_bars_complete()
	if self.step ~= Enums.tutorial_step.explore then
		return
	end
	self.world:emit("toggle_component", self.e_player, "can_move", true)
	self.world:emit("toggle_component", self.e_player, "can_interact", true)
	self.world:emit("toggle_component", self.e_player, "can_run", false)
end

return Tutorial
