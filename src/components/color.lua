Concord.component("alpha_range", function(c, min, max)
	assert(type(min) == "number", min)
	assert(type(max) == "number", max)
	c.min = min
	c.max = max
end)

Concord.component("color", function(c, color, original)
	assert(type(color) == "table", color)
	if original then
		assert(type(original) == "table", original)
	end
	c.value = { unpack(color) }
	c.original = original or { unpack(color) }
end)

Concord.component("color_fade_in_out", function(c, duration, count)
	assert(type(duration) == "number", duration)
	if count then
		assert(type(count) == "number", count)
	end
	c.duration = duration
	c.count = count or 0
end)

Concord.component("fade_to_black", function(c, duration, delay)
	assert(type(duration) == "number", duration)
	if delay then
		assert(type(delay) == "number", delay)
	end
	c.duration = duration
	c.delay = delay or 0
end)

local c_lc = Concord.component("lerp_colors", function(c, colors, duration, delay)
	assert(type(colors) == "table", colors)
	if duration then
		assert(type(duration) == "number", duration)
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
	assert(type(target) == "table", target)
	assert(type(duration) == "number", duration)
	if delay then
		assert(type(delay) == "number", delay)
	end
	c.target = { unpack(target) }
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("color_fade_in", function(c, duration, delay)
	assert(type(duration) == "number", duration)
	if delay then
		assert(type(delay) == "number", delay)
	end
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("color_fade_out", function(c, duration, delay)
	assert(type(duration) == "number", duration)
	if delay then
		assert(type(delay) == "number", delay)
	end
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("fade_in_target_alpha", function(c, alpha)
	assert(type(alpha) == "number", alpha)
	c.value = alpha
end)

Concord.component("remove_blink_on_end")
Concord.component("blink", function(c, dur, count)
	assert(type(dur) == "number", dur)
	assert(type(count) == "number", count)
	c.dur = dur
	c.count = count * 2
	c.completed = 0
end)
