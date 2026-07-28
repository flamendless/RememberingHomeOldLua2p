local Fog = Concord.system({
	pool = { "id", "fog", "noise_texture", "pos", "color", "transform" },
})

function Fog:init(world)
	self.world = world
	self.pool.onAdded = function(pool, e)
		e:get("sprite").image = e:get("noise_texture").texture
	end
end

function Fog:update()
	for _, e in ipairs(self.pool) do
		if not e:has("hidden") then
			local fog = e:get("fog")
			fog.shader:send("u_fog_speed", fog.speed)
			fog.shader:send("u_time", love.timer.getTime())
		end
	end
end

function Fog:draw_fog(e)
	if DEV and DevTools.show and not DevTools.flags.fog then
		return
	end

	assert(e.__isEntity and e:has("fog"), e)

	local fog = e:get("fog")
	local color = e:get("color").value
	love.graphics.setColor(color)
	love.graphics.setShader(fog.shader)
	e.renderer.render(e)
	love.graphics.setShader()
end

function Fog:fade_in_fog(target_id, dur)
	assert:type(target_id, "string")
	assert:type(dur, "number")
	for _, e in ipairs(self.pool) do
		local id = e:get("id").value
		if id == target_id then
			e:remove("hidden"):give("color_fade_in", dur)
			break
		end
	end
end

function Fog:fade_out_fog(target_id, dur)
	assert:type(target_id, "string")
	assert:type(dur, "number")
	for _, e in ipairs(self.pool) do
		local id = e:get("id").value
		if id == target_id then
			e:give("color_fade_out", dur):give("color_fade_out_finish", "hide_entity", 0, e)
			break
		end
	end
end

return Fog
