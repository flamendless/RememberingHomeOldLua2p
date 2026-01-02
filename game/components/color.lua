Concord.component("alpha_range", function(c, range)
	ASSERT(range:type() == "vec2")
	c.value = range
end)

Concord.component("color", function(c, color, original)
	ASSERT(type(color) == "table")
	SASSERT(original, type(original) == "table")
	c.value = {unpack(color)}
	c.original = original or {unpack(color)}
end)

Concord.component("color_fade_in", function(c, duration, count)
	ASSERT(type(duration) == "number")
	SASSERT(count, type(count) == "number")
	c.duration = duration
	c.count = count or 0
end)

--TODO: (Brandon)
Concord.component("color_fade_in_out", function(c, duration, count)
	ASSERT(type(duration) == "number")
	SASSERT(count, type(count) == "number")
	c.duration = duration
	c.count = count or 0
end)

Concord.component("fade_to_black", function(c, duration, delay)
	ASSERT(type(duration) == "number")
	SASSERT(delay, type(delay) == "number")
	c.duration = duration
	c.delay = delay or 0
end)

local c_lc = Concord.component("lerp_colors", function(c, colors, duration, delay)
	ASSERT(type(colors) == "table")
	SASSERT(duration, type(duration) == "number")
	SASSERT(delay, type(delay) == "number")
	if DEV then
		for _, color in ipairs(colors) do
			ASSERT(type(color) == "table")
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
	ASSERT(type(target) == "table")
	ASSERT(type(duration) == "number")
	SASSERT(delay, type(delay) == "number")
	c.target = {unpack(target)}
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("color_fade_out", function(c, duration, delay)
	ASSERT(type(duration) == "number")
	SASSERT(delay, type(delay) == "number")
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("fade_in_target_alpha", function(c, alpha)
	ASSERT(type(alpha) == "number")
	c.value = alpha
end)

Concord.component("remove_blink_on_end")
Concord.component("blink", function(c, dur, count)
	ASSERT(type(dur) == "number")
	ASSERT(type(count) == "number")
	c.dur = dur
	c.count = count * 2
	c.completed = 0
end)
