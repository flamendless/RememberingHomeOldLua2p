local Flux = require("modules.flux.flux")

local Fade = {}

local f_duration = 1
local f_delay = 0.5
local f_color = { 0, 0, 0, 0 }

function Fade.fade_out(on_complete, duration, delay)
	if on_complete then
		if not (type(on_complete) == "function") then
			error('Assertion failed: type(on_complete) == "function"')
		end
	end
	if duration then
		if not (type(duration) == "number") then
			error('Assertion failed: type(duration) == "number"')
		end
	end
	if delay then
		if not (type(delay) == "number") then
			error('Assertion failed: type(delay) == "number"')
		end
	end
	local f = Flux.to(f_color, duration or f_duration, { [4] = 1 }):delay(delay or f_delay)

	if on_complete then
		f:oncomplete(on_complete)
	end
end

function Fade.fade_in(on_complete, duration, delay)
	if on_complete then
		if not (type(on_complete) == "function") then
			error('Assertion failed: type(on_complete) == "function"')
		end
	end
	if duration then
		if not (type(duration) == "number") then
			error('Assertion failed: type(duration) == "number"')
		end
	end
	if delay then
		if not (type(delay) == "number") then
			error('Assertion failed: type(delay) == "number"')
		end
	end
	local f = Flux.to(f_color, duration or f_duration, { [4] = 0 }):delay(delay or f_delay)

	if on_complete then
		f:oncomplete(on_complete)
	end
end

function Fade.set_alpha(a)
	if not (type(a) == "number") then
		error('Assertion failed: type(a) == "number"')
	end
	f_color[4] = a
end

function Fade.draw()
	local w, h = love.graphics.getDimensions()
	love.graphics.setColor(Fade.getColor())
	love.graphics.rectangle("fill", 0, 0, w, h)
end

function Fade.set_color(color)
	if not (type(color) == "table") then
		error('Assertion failed: type(color) == "table"')
	end
	f_color[1] = color[1] or f_color[1]
	f_color[2] = color[2] or f_color[2]
	f_color[3] = color[3] or f_color[3]
	f_color[4] = color[4] or f_color[4]
end

function Fade.getColor()
	return f_color
end

return Fade
