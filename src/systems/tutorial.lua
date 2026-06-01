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

		local cam = self.world:getResource("camera")
		local pos = e_player.pos
		local col = e_player.collider
		local x, y = pos.x - col.w_h, pos.y + col.h_h
		x, y = cam:toScreen(x, y)

		self.world:emit("show_key_at", Enums.show_keys.dialogue, true, vec2(x, y))
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
