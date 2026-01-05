Concord.component("alpha_range", function(c, min, max)
	if not (type(min) == "number") then
		error('Assertion failed: type(min) == "number"')
	end
	if not (type(max) == "number") then
		error('Assertion failed: type(max) == "number"')
	end
	c.min = min
	c.max = max
end)

Concord.component("color", function(c, color, original)
	if not (type(color) == "table") then
		error('Assertion failed: type(color) == "table"')
	end
	if original then
		if not (type(original) == "table") then
			error('Assertion failed: type(original) == "table"')
		end
	end
	c.value = { unpack(color) }
	c.original = original or { unpack(color) }
end)

Concord.component("color_fade_in_out", function(c, duration, count)
	if not (type(duration) == "number") then
		error('Assertion failed: type(duration) == "number"')
	end
	if count then
		if not (type(count) == "number") then
			error('Assertion failed: type(count) == "number"')
		end
	end
	c.duration = duration
	c.count = count or 0
end)

Concord.component("fade_to_black", function(c, duration, delay)
	if not (type(duration) == "number") then
		error('Assertion failed: type(duration) == "number"')
	end
	if delay then
		if not (type(delay) == "number") then
			error('Assertion failed: type(delay) == "number"')
		end
	end
	c.duration = duration
	c.delay = delay or 0
end)

local c_lc = Concord.component("lerp_colors", function(c, colors, duration, delay)
	if not (type(colors) == "table") then
		error('Assertion failed: type(colors) == "table"')
	end
	if duration then
		if not (type(duration) == "number") then
			error('Assertion failed: type(duration) == "number"')
		end
	end

	c.index = 1
	c.colors = colors
	c.duration = duration or 1.5
	c.delay = delay or 0.15
end)

function c_lc:serialize()
	return {
		index = self.index,
		colors = self.colors,
		duration = self.duration,
		delay = self.delay,
	}
end

function c_lc:deserialize(data)
	self.index = data.index
	self.colors = data.colors
	self.duration = data.duration
	self.delay = data.delay
end

Concord.component("target_color", function(c, target, duration, delay)
	if not (type(target) == "table") then
		error('Assertion failed: type(target) == "table"')
	end
	if not (type(duration) == "number") then
		error('Assertion failed: type(duration) == "number"')
	end
	if delay then
		if not (type(delay) == "number") then
			error('Assertion failed: type(delay) == "number"')
		end
	end
	c.target = { unpack(target) }
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("color_fade_in", function(c, duration, delay)
	if not (type(duration) == "number") then
		error('Assertion failed: type(duration) == "number"')
	end
	if delay then
		if not (type(delay) == "number") then
			error('Assertion failed: type(delay) == "number"')
		end
	end
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("color_fade_out", function(c, duration, delay)
	if not (type(duration) == "number") then
		error('Assertion failed: type(duration) == "number"')
	end
	if delay then
		if not (type(delay) == "number") then
			error('Assertion failed: type(delay) == "number"')
		end
	end
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("fade_in_target_alpha", function(c, alpha)
	if not (type(alpha) == "number") then
		error('Assertion failed: type(alpha) == "number"')
	end
	c.value = alpha
end)

Concord.component("remove_blink_on_end")
Concord.component("blink", function(c, dur, count)
	if not (type(dur) == "number") then
		error('Assertion failed: type(dur) == "number"')
	end
	if not (type(count) == "number") then
		error('Assertion failed: type(count) == "number"')
	end
	c.dur = dur
	c.count = count * 2
	c.completed = 0
end)
