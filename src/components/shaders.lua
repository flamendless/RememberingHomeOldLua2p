--TODO: (Brandon) maybe this is not needed anymore
Concord.component("no_shader")

Concord.component("fog", function(c, speed)
	if type(speed) ~= "number" then
		error('Assertion failed: type(speed) == "number"')
	end
	c.shader = love.graphics.newShader(Shaders.paths.fog)
	c.speed = speed
end)
