--TODO: (Brandon) maybe this is not needed anymore
Concord.component("no_shader")

Concord.component("fog", function(c, speed)
	assert(type(speed) == "number", speed)
	c.shader = love.graphics.newShader(Shaders.paths.fog)
	c.speed = speed
end)
