local Typewriter = Concord.system({
	pool = { "text", "reflowprint" },
})

function Typewriter:init(world)
	self.world = world
end

function Typewriter:update(dt)
	for _, e in ipairs(self.pool) do
		if not e:has("text_can_proceed") and not e:has("text_skipped") then
			local text = e:get("text")
			local rfp = e:get("reflowprint")
			rfp.dt = rfp.dt + dt * rfp.speed
			if rfp.dt * #text.value > #text.value then
				e:give("text_can_proceed")
			elseif Inputs.pressed(Enums.input.interact) then
				rfp.dt = #text.value - 1
				e:give("text_skipped")
			end
		end
	end
end

return Typewriter
