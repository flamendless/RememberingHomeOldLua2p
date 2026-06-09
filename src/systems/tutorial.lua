local Tutorial = Concord.system({})

local MAX_HOLD_INTERACT_TIMER = 3

function Tutorial:init(world)
	self.world = world

	self.state = Settings.current.tutorial

	if self.state then
		self.world:emit("create_dialogue_key")
	end

	self.step = Enums.tutorial_step.waiting
end

function Tutorial:tutorial_step_set(step)
	assert(Enums.tutorial_step[step], step)
	Log.info("Tutorial step", "from:", self.step, "to:", step)
	self.step = step

	if self.step == Enums.tutorial_step.interact then
		local e_player = self.world:getResource("e_player")
		assert(e_player ~= nil)

		local pos = e_player.pos
		local col = e_player.collider
		local tx, ty = pos.x - col.w_h + 8, pos.y + col.h_h + 4
		local bx = tx - 72
		local by = ty + 8
		local n = 5
		local gapx = (tx - bx) / n
		local gapy = (ty - by) / n
		local r = -90
		local scale = 0.4

		for i = 1, n do
			local x = bx + gapx * i
			local y = by + gapy * i + love.math.random(-3, 3)
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
				:give("id", "hand_decal" .. i)
				:give("key", "hand_decal" .. i)
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

			scale = scale + love.math.random(2, 4) / 100
			r = r - love.math.random(15, 30)

			local target_opacity = love.math.random(6, 9) / 10
			if i == n then target_opacity = 0.9 end

			local dur = love.math.random(3, 8) / 10
			local delay = i + love.math.random(3, 7) / 10
			Flux.to(
				e_hand.decals_shaders.data,
				dur,
				{ opacity = target_opacity }
			)
				:delay(delay)
				:oncomplete(function()
					if i == n then
						local cam = self.world:getResource("camera")
						local tw, th = self.world:getResource("tex_glow"):getDimensions()
						local hx, hy = e_hand.pos.x - tw * scale / 2, e_hand.pos.y - th * scale / 2
						local ox, oy = 3, 5
						local keyx, keyy = cam:toScreen(hx + ox, hy + oy)
						self.world:emit(
							"show_key_at",
							Enums.show_keys.dialogue,
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

						self:tutorial_step_set(Enums.tutorial_step.waiting_interact)

					else
						Flux.to(
							e_hand.decals_shaders.data,
							dur * 0.9,
							{ opacity = 0 }
						):delay(delay * 0.3)
							:oncomplete(function()
								e_hand:destroy()
							end)
					end
				end)
		end

	elseif self.step == Enums.tutorial_step.waiting_interact then
		self.hold_interact_timer = 0
		self.e_key = self.world:getEntityByKey("dialogue_proceed_key")
		assert(self.e_key ~= nil)
		self.e_hand = self.world:getEntityByKey("hand_decal5")
		assert(self.e_hand ~= nil)

	elseif self.step == Enums.tutorial_step.done_waiting_interact then
		self.e_key:destroy()
		self.e_glow:destroy()
		self.e_hand:destroy()
		self.hold_interact_timer = nil
		self.e_player = self.world:getResource("e_player")
		assert(self.e_player ~= nil)
		self.e_player:remove("hidden")
	end
end

function Tutorial:state_update(dt)
	if not self.state then return end

	if self.step == Enums.tutorial_step.waiting_interact then
		if Inputs.down("interact") then
			self.hold_interact_timer = self.hold_interact_timer + dt
		else
			self.hold_interact_timer = self.hold_interact_timer - dt * 1.5
		end

		self.hold_interact_timer = mathx.clamp(self.hold_interact_timer, 0, MAX_HOLD_INTERACT_TIMER)

		local progress = mathx.clamp(self.hold_interact_timer, 0, 1)
		self.e_key.color.value[4] = 1 - progress
		self.e_hand.decals_shaders.data.blood_amount = progress
		self.e_hand.decals_shaders.data.damage_amount = progress
		self.e_hand.decals_shaders.data.distort_amount = progress

		if progress >= 1 then
			self:tutorial_step_set(Enums.tutorial_step.done_waiting_interact)
		end
	end
end

function Tutorial:state_draw()
	if not self.state then return end
	if DEV then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.print("IN TUTORIAL: " .. self.step, 0, 38)
		if self.hold_interact_timer then
			love.graphics.print("HOLD TIMER: " .. self.hold_interact_timer, 0, 72)
		end
	end
end

return Tutorial
