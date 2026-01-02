local Typewriter = Concord.system({
	pool = {"text", "reflowprint"},
})

function Typewriter:init(world)
	self.world = world
end

function Typewriter:update(dt)
	for _, e in ipairs(self.pool) do
		if not e.text_can_proceed and not e.text_skipped then
			local text = e.text.value
			local rfp = e.reflowprint
			rfp.dt = rfp.dt + dt * rfp.speed
			if rfp.dt * #text > #text then
				e:give("text_can_proceed")
			elseif Inputs.pressed("interact") then
				rfp.dt = #text - 1
				e:give("text_skipped")
			end
		end
	end
end

return Typewriter
