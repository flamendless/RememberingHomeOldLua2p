local Fade = {}

if DEV then
	function Fade.dev_reset()
		Fade.state = Enums.fade.none
		Fade.duration = 0
		Fade.delay = 0
	end
	function Fade.dev_set(state, dur, delay)
		Fade.state = state
		Fade.duration = dur or 0
		Fade.delay = delay or 0
	end
	Fade.dev_reset()
end

local f_duration = 1
local f_delay = 0.5
local f_color = { 0, 0, 0, 0 }

function Fade.fade_out(on_complete, duration, delay)
	if DEV then
		Fade.dev_set(Enums.fade.fade_out, duration, delay)
	end

	if on_complete then
		assert(type(on_complete) == "function", on_complete)
	end
	if duration then
		assert(type(duration) == "number", duration)
	end
	if delay then
		assert(type(delay) == "number", delay)
	end
	local f = Flux.to(f_color, duration or f_duration, { [4] = 1 }):delay(delay or f_delay)

	if on_complete then
		f:oncomplete(on_complete)
	end
end

function Fade.fade_in(on_complete, duration, delay)
	if DEV then
		Fade.dev_set(Enums.fade.fade_in, duration, delay)
	end

	if on_complete then
		assert(type(on_complete) == "function", on_complete)
	end
	if duration then
		assert(type(duration) == "number", duration)
	end
	if delay then
		assert(type(delay) == "number", delay)
	end
	local f = Flux.to(
		f_color,
		duration or f_duration,
		{ [4] = 0 }
	):delay(delay or f_delay)

	if on_complete then
		f:oncomplete(on_complete)
	end
end

function Fade.set_alpha(a)
	assert(type(a) == "number", a)
	f_color[4] = a
end

function Fade.draw()
	local w, h = love.graphics.getDimensions()
	love.graphics.setColor(Fade.getColor())
	love.graphics.rectangle("fill", 0, 0, w, h)
end

function Fade.set_color(color)
	assert(type(color) == "table", color)
	f_color[1] = color[1] or f_color[1]
	f_color[2] = color[2] or f_color[2]
	f_color[3] = color[3] or f_color[3]
	f_color[4] = color[4] or f_color[4]
end

function Fade.getColor()
	return f_color
end

return Fade
