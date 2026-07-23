local Tutorial = Concord.system({})

local MAX_HOLD_INTERACT_TIMER = 3

function Tutorial:init(world)
	self.world = world

	self.state = Settings.current.tutorial

	if self.state then
		self.world:emit("create_dialogue_key")
		self.world:emit("create_left_key")
		self.world:emit("create_right_key")
		self.world:emit("create_lighter_key")
		self.e_dialogue_car1 = Concord.entity(self.world)
			:give("id", "dialogue_car1")
			:give("dialogue_key", "car_doors")
	end

	self.step = Enums.tutorial_step.waiting
end

function Tutorial:show_hands_trail(
	n,
	startx,
	starty,
	targetx,
	targety,
	startrot,
	show_key,
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
		show_key,
		next_step,
		is_instant
	)
	assert(Enums.show_keys[show_key])
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

		local e_hand = Concord.entity(self.world)
			:give("id", self.step .. "_hand_decal" .. i)
			:give("key", self.step .. "_hand_decal" .. i)
			:give("z_index", MAX_Z)
			:give("pos", x, y)
			:give("color", Palette.diffuse.hand_decals)
			:give("decals", Enums.decals.hand)
			:give("decals_shaders", Enums.shaders.hand, {
				time = 0,
				opacity = 0,
				blood_amount = blood,
				damage_amount = dmg,
				distort_amount = distort,
				scale = { scale, scale },
				rotation = r,
			})

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

		Flux.to(e_hand.decals_shaders.data, dur, { opacity = target_opacity })
			:delay(delay)
			:oncomplete(function()
				if i == n then
					self.prev_hx, self.prev_hy = e_hand.pos.x, e_hand.pos.y
					local cam = self.world:getResource("camera")
					local tw, th = self.world:getResource("tex_glow"):getDimensions()
					local hx, hy = e_hand.pos.x - tw * scale / 2, e_hand.pos.y - th * scale / 2
					local ox, oy = 3, 5
					local keyx, keyy = cam:toScreen(hx + ox, hy + oy)
					self.world:emit(
						"show_key_at",
						show_key,
						true,
						vec2(keyx, keyy)
					)
					self.e_glow = Concord.entity(self.world):assemble(
							Assemblages.BillboardGlow.create,
							hx, hy,
							9,
							0.4,
							Palette.diffuse.glow_hand_decals,
							1.5
						)
						:give("glow_pulse", 6, 0.2)

					self:tutorial_step_set(next_step)

				else
					Flux.to(e_hand.decals_shaders.data, dur * 0.9, { opacity = 0 })
					:delay(delay * 0.3)
					:oncomplete(function() e_hand:destroy() end)
				end
			end)
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
		self:show_hands_trail(5, bx, by, tx, ty, 90, Enums.show_keys.dialogue, Enums.tutorial_step.waiting_interact, false)

	elseif self.step == Enums.tutorial_step.waiting_interact then
		self.hold_interact_timer = 0
		self.hit_n = 0
		self.e_interact_key = self.world:getEntityByKey("dialogue_proceed_key")

	elseif self.step == Enums.tutorial_step.done_waiting_interact then
		self.world:emit("force_end_dialogue")
		--TODO: play car door open sound
		self.e_interact_key:destroy()
		self.e_glow:destroy()
		self.e_last_hand:destroy()
		self.hold_interact_timer = nil
		self.e_player:remove("hidden")
		self:tutorial_step_set(Enums.tutorial_step.show_left)

	elseif self.step == Enums.tutorial_step.show_left then
		local pos = self.e_player.pos
		local col = self.e_player.collider
		local tx, ty = pos.x - col.w_h - 60, pos.y + col.h_h
		local bx = self.prev_hx
		local by = self.prev_hy
		self:show_hands_trail(5, bx, by, tx, ty, 270, Enums.show_keys.left, Enums.tutorial_step.waiting_left, false)
		self.left_start_x = self.e_player.pos.x
		self.left_target_x = tx - 18

		self.e_left_key = self.world:getEntityByKey("left_proceed_key")
		assert(self.e_left_key ~= nil)

	elseif self.step == Enums.tutorial_step.waiting_left then
		self.e_player:give("can_move"):give("can_move_left_only")

	elseif self.step == Enums.tutorial_step.show_left_interact then
		self.world:emit("create_dialogue_key")

		assert(self.e_left_key ~= nil)
		self.e_left_key:destroy()

		local tx, ty = self.e_last_hand.pos.x, self.e_last_hand.pos.y
		self.e_last_hand:destroy()
		self.e_glow:destroy()

		GameStates.after(1, function ()
			self:show_hands_trail(
				5,
				tx, ty,
				tx, ty,
				0,
				Enums.show_keys.dialogue,
				Enums.tutorial_step.waiting_left_interact,
				true
			)
		end)

	elseif self.step == Enums.tutorial_step.waiting_left_interact then
		self.e_interact_key = self.world:getEntityByKey("dialogue_proceed_key")
		assert(self.e_interact_key ~= nil)
		self.is_fluxing = false

	elseif self.step == Enums.tutorial_step.done_left_interact then
		self.world:emit(
			"start_dialogue",
			self.e_player,
			self.e_dialogue_car1,
			"car_headlights"
		)

	elseif self.step == Enums.tutorial_step.show_right then
		local startx, starty = self.e_last_hand.pos.x, self.e_last_hand.pos.y

		local pos = self.e_player.pos
		local col = self.e_player.collider
		local tx, ty = pos.x - col.w_h + 144, pos.y + col.h_h + 4
		self:show_hands_trail(
			8,
			startx, starty,
			tx, ty,
			0,
			Enums.show_keys.right,
			Enums.tutorial_step.waiting_right,
			false
		)

		self.right_start_x = self.e_player.pos.x
		self.right_target_x = tx + 7

		self.e_right_key = self.world:getEntityByKey("right_proceed_key")
		assert(self.e_right_key ~= nil)

	elseif self.step == Enums.tutorial_step.waiting_right then
		self.e_player:give("can_move"):remove("can_move_left_only"):give("can_move_right_only")

	elseif self.step == Enums.tutorial_step.show_right_interact then
		self.world:emit("player_force_face_dir", -1)
		self.world:emit("create_dialogue_key")

		assert(self.e_right_key ~= nil)
		self.e_right_key:destroy()

		local tx, ty = self.e_last_hand.pos.x, self.e_last_hand.pos.y
		self.e_last_hand:destroy()
		self.e_glow:destroy()

		GameStates.after(1, function ()
			self:show_hands_trail(
				5,
				tx, ty,
				tx, ty,
				0,
				Enums.show_keys.dialogue,
				Enums.tutorial_step.waiting_right_interact,
				true
			)
		end)

	elseif self.step == Enums.tutorial_step.waiting_right_interact then
		self.world:emit("player_force_face_dir", -1)
		self.is_fluxing = false
		self.e_interact_key = self.world:getEntityByKey("dialogue_proceed_key")
		assert(self.e_interact_key)

	elseif self.step == Enums.tutorial_step.done_right_interact then
		self.e_interact_key:destroy()
		self.world:emit("player_force_face_dir", -1)
		-- TODO: open the trunk animation?
		-- TODO: play trunk open sound
		GameStates.after(1, function()
			self.world:emit(
				"start_dialogue",
				self.e_player,
				self.e_dialogue_car1,
				"car_trunk_pre"
			)
		end)

	elseif self.step == Enums.tutorial_step.show_lighter then
		local tx, ty = self.e_last_hand.pos.x, self.e_last_hand.pos.y
		self:show_hands_trail(
			5,
			tx, ty,
			tx, ty,
			0,
			Enums.show_keys.lighter,
			Enums.tutorial_step.wait_lighter_trigger,
			true
		)

	elseif self.step == Enums.tutorial_step.wait_lighter_trigger then
		self.e_lighter_key = self.world:getEntityByKey("dialogue_lighter_key")
		self.triggered_lighter = false

	elseif self.step == Enums.tutorial_step.done_lighter_trigger then
		self.world:emit("on_toggle_equip_lighter")
		-- TODO: show lighter / play animation
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

function Tutorial:state_update(dt)
	if not self.state then return end

	if self.step == Enums.tutorial_step.waiting_interact then
		if Inputs.pressed("interact") or Inputs.down("interact") then
			self.hold_interact_timer = self.hold_interact_timer + dt * 0.3
		end

		self.hold_interact_timer = mathx.clamp(self.hold_interact_timer, 0, MAX_HOLD_INTERACT_TIMER)

		local progress = mathx.clamp(self.hold_interact_timer, 0, 1)
		self.e_interact_key.color.value[4] = 1 - progress
		self.e_last_hand.decals_shaders.data.blood_amount = progress
		self.e_last_hand.decals_shaders.data.damage_amount = progress
		self.e_last_hand.decals_shaders.data.distort_amount = progress

		-- TODO: every quarter of progress, play sound of like hitting car door to open
		if self.hit_n == 0 and progress >= 0.1 and progress <= 0.25 then
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
			self.world:emit("screen_shake", 0.15, 0.01)
		elseif self.hit_n == 2 and progress > 0.5 and progress <= 0.75 then
			self.hit_n = 3
			self.world:emit("screen_shake", 0.2, 0.015)
			self.world:emit(
				"start_dialogue",
				self.e_player,
				self.e_dialogue_car1,
				"car_doors2"
			)
		elseif self.hit_n == 3 and progress > 0.75 and progress <= 0.99 then
			self.hit_n = 4
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

	elseif self.step == Enums.tutorial_step.waiting_left then
		local current = self.e_player.pos.x
		local progress = (self.left_start_x - current) / (self.left_start_x - self.left_target_x)
		progress = mathx.clamp(progress, 0, 1)

		self.e_left_key.color.value[4] = 1 - progress
		self.e_last_hand.decals_shaders.data.blood_amount = progress
		self.e_last_hand.decals_shaders.data.damage_amount = progress
		self.e_last_hand.decals_shaders.data.distort_amount = progress

		if progress >= 1 then
			self.e_player:remove("can_move"):remove("can_move_left_only")
			self.world:__flush()
			self.world:emit("player_stop")
			self.world:emit("player_force_face_dir", 1)
			self:tutorial_step_set(Enums.tutorial_step.show_left_interact)
		end

	elseif self.step == Enums.tutorial_step.waiting_left_interact and not self.is_fluxing then
		if Inputs.pressed("interact") then
			self.is_fluxing = true
			local progress = {value = 0}
			Flux.to(progress, 2, { value = 1 }):onupdate(function()
				self.e_interact_key.color.value[4] = 1 - progress.value
				self.e_last_hand.decals_shaders.data.blood_amount = progress.value
				self.e_last_hand.decals_shaders.data.damage_amount = progress.value
				self.e_last_hand.decals_shaders.data.distort_amount = progress.value
			end):oncomplete(function()
				self.e_interact_key:destroy()
				self.e_last_hand:destroy()
				self.e_glow:destroy()
				self:tutorial_step_set(Enums.tutorial_step.done_left_interact)
			end)
		end

	elseif self.step == Enums.tutorial_step.waiting_right then
		local current = self.e_player.pos.x
		local progress = (self.right_start_x - current) / (self.right_start_x - self.right_target_x)
		progress = mathx.clamp(progress, 0, 1)

		self.e_right_key.color.value[4] = 1 - progress
		self.e_last_hand.decals_shaders.data.blood_amount = progress
		self.e_last_hand.decals_shaders.data.damage_amount = progress
		self.e_last_hand.decals_shaders.data.distort_amount = progress

		if progress >= 1 then
			self.e_player:remove("can_move"):remove("can_move_right_only")
			self.world:__flush()
			self.world:emit("player_stop")
			self.world:emit("player_force_face_dir", -1)
			self:tutorial_step_set(Enums.tutorial_step.show_right_interact)
		end

	elseif self.step == Enums.tutorial_step.waiting_right_interact and not self.is_fluxing then
		if Inputs.pressed("interact") then
			self.is_fluxing = true
			local progress = {value = 0}
			Flux.to(progress, 2, { value = 1 }):onupdate(function()
				self.e_interact_key.color.value[4] = 1 - progress.value
				self.e_last_hand.decals_shaders.data.blood_amount = progress.value
				self.e_last_hand.decals_shaders.data.damage_amount = progress.value
				self.e_last_hand.decals_shaders.data.distort_amount = progress.value
			end):oncomplete(function()
				self.e_interact_key:destroy()
				self.e_last_hand:destroy()
				self.e_glow:destroy()
				self:tutorial_step_set(Enums.tutorial_step.done_right_interact)
			end)
		end

	elseif self.step == Enums.tutorial_step.wait_lighter_trigger and not self.triggered_lighter then
		if Inputs.pressed("lighter") then
			self.triggered_lighter = true
			--TODO: instead of fading out, the decal should like explode/burn quickly because of the light?
			local progress = {value = 0}
			Flux.to(progress, 1, { value = 1 }):onupdate(function()
				self.e_lighter_key.color.value[4] = 1 - progress.value
				self.e_last_hand.decals_shaders.data.blood_amount = progress.value
				self.e_last_hand.decals_shaders.data.damage_amount = progress.value
				self.e_last_hand.decals_shaders.data.distort_amount = progress.value
			end):oncomplete(function()
				self.e_lighter_key:destroy()
				self.e_last_hand:destroy()
				self.e_glow:destroy()
				self:tutorial_step_set(Enums.tutorial_step.done_lighter_trigger)
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
		self.world:emit("on_toggle_equip_lighter")
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
