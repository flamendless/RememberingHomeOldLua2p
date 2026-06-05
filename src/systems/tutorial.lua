local Tutorial = Concord.system({})

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
	self.step = step

	if self.step == Enums.tutorial_step.interact then
		local e_player = self.world:getResource("e_player")
		assert(e_player ~= nil)

		local pos = e_player.pos
		local col = e_player.collider
		local tx, ty = pos.x - col.w_h, pos.y + col.h_h
		local bx = tx - 72
		local by = ty + 8
		local n = 5
		local gapx = (tx - bx) / n
		local gapy = (ty - by) / n
		local r = 90
		local scale = 0.4

		for i = 1, n do
			local x = bx + gapx * i
			local y = by + gapy * i + love.math.random(-3, 3)

			local e_hand = Concord.entity(self.world)
				:give("id", "hand_decal" .. i)
				:give("z_index", MAX_Z)
				:give("pos", x, y)
				:give("color", Palette.colors.white)
				:give("decals", Enums.decals.hand)
				:give("decals_shaders", Enums.shaders.hand, {
					time = 0,
					opacity = 0,
					blood_amount = 0.8,
					damage_amount = 0.8,
					distort_amount = 0.9,
					scale = { scale, scale },
					rotation = r,
				})

			scale = scale + love.math.random(2, 4) / 100
			r = r - love.math.random(15, 30)

			local target_opacity = love.math.random(6, 9) / 10
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
						local hx, hy = e_hand.pos.x, e_hand.pos.y
						local keyx, keyy = cam:toScreen(hx, hy)
						self.world:emit(
							"show_key_at",
							Enums.show_keys.dialogue,
							true,
							vec2(keyx, keyy)
						)
						local _ = Concord.entity(self.world):assemble(
							Assemblages.BillboardGlow.create,
							hx,
							hy,
							9,
							1,
							Palette.colors.glow_hand_decals,
							1
						)
					else
						Flux.to(
							e_hand.decals_shaders.data,
							dur * 0.75,
							{ opacity = 0 }
						):delay(delay * 0.8)
						:oncomplete(function()
							e_hand:destroy()
						end)
					end
				end)
		end
	end
end

function Tutorial:state_update(dt)
	if not self.state then return end
end

function Tutorial:state_draw()
	if not self.state then return end
	if DEV then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.print("IN TUTORIAL: " .. self.step, 0, 38)
	end
end

return Tutorial
