local LightSwitch = Concord.system({
	pool_lights = { "id", "point_light", "pos", "diffuse", "light_switch_id" },
})

function LightSwitch:init(world)
	self.world = world
end

function LightSwitch:toggle_light_switch(_, _, choice)
	for _, e in ipairs(self.pool_lights) do
		local valid = true
		if choice then
			local ls_id = e.light_switch_id.value
			valid = ls_id == choice
		end

		if valid then
			--TODO: (Brandon) play sound
			if e.light_disabled then
				e:remove("light_disabled")
			else
				e:give("light_disabled")
			end
		end
	end
end

return LightSwitch
