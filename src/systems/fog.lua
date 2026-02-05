local Fog = Concord.system({
	pool = { "id", "fog", "noise_texture", "pos", "color", "transform" },
})

function Fog:init(world)
	self.world = world
	self.pool.onAdded = function(pool, e)
		e.sprite.image = e.noise_texture.texture
	end
end

function Fog:update()
	for _, e in ipairs(self.pool) do
		if not e.hidden then
			local fog = e.fog
			fog.shader:send("u_fog_speed", fog.speed)
			fog.shader:send("u_time", love.timer.getTime())
		end
	end
end

function Fog:draw_fog(e)
	if DEV and DevTools.show and not DevTools.flags.fog then
		return
	end

	if not e.__isEntity then
		error(e.fog)
	end

	local fog = e.fog
	local color = e.color.value
	love.graphics.setColor(color)
	love.graphics.setShader(fog.shader)
	e.renderer.render(e)
	love.graphics.setShader()
end

function Fog:fade_in_fog(target_id, dur)
	if type(target_id) ~= "string" then
		error('Assertion failed: type(target_id) == "string"')
	end
	if type(dur) ~= "number" then
		error('Assertion failed: type(dur) == "number"')
	end
	for _, e in ipairs(self.pool) do
		local id = e.id.value
		if id == target_id then
			e:remove("hidden"):give("color_fade_in", dur)
			break
		end
	end
end

function Fog:fade_out_fog(target_id, dur)
	if type(target_id) ~= "string" then
		error('Assertion failed: type(target_id) == "string"')
	end
	if type(dur) ~= "number" then
		error('Assertion failed: type(dur) == "number"')
	end
	for _, e in ipairs(self.pool) do
		local id = e.id.value
		if id == target_id then
			e:give("color_fade_out", dur):give("color_fade_out_finish", "hide_entity", 0, e)
			break
		end
	end
end

return Fog
