local LightSwitch = Concord.system({
	pool_lights = { "id", "point_light", "pos", "diffuse", "light_switch_id" },
})

function LightSwitch:init(world)
	assert:world(world)
	self.world = world
end

local function light_is_off(e)
	if e:has("light_disabled") then
		return true
	end
	if e:has("light_ramp") then
		local ramp = e:get("light_ramp")
		if ramp.active and ramp.to_on then
			return true
		end
	end
	return false
end

function LightSwitch:toggle_light_switch(_, _, choice)
	for _, e in ipairs(self.pool_lights) do
		local valid = true
		if choice then
			local ls_id = e:get("light_switch_id").value
			valid = ls_id == choice
		end

		if valid then
			self.world:emit("play_sound_on_entity", e, Enums.sfx.light_switch)
			self.world:emit("set_light_enabled", e, light_is_off(e))
		end
	end
end

return LightSwitch
