Concord.component("alpha_range", function(c, min, max)
	assert:type(min, "number")
	assert:type(max, "number")
	c.min = min
	c.max = max
end)

Concord.component("color", function(c, color, original)
	assert:type(color, "table")
	assert:type_or_nil(original, "table")
	c.value = { unpack(color) }
	c.original = original or { unpack(color) }
end)

Concord.component("color_fade_in_out", function(c, duration, count)
	assert:type(duration, "number")
	assert:type_or_nil(count, "number")
	c.duration = duration
	c.count = count or 0
end)

Concord.component("fade_to_black", function(c, duration, delay)
	assert:type(duration, "number")
	assert:type_or_nil(delay, "number")
	c.duration = duration
	c.delay = delay or 0
end)

local c_lc = Concord.component("lerp_colors", function(c, colors, duration, delay)
	assert:type(colors, "table")
	assert:type_or_nil(duration, "number")

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
	assert:type(target, "table")
	assert:type(duration, "number")
	assert:type_or_nil(delay, "number")
	c.target = { unpack(target) }
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("color_fade_in", function(c, duration, delay)
	assert:type(duration, "number")
	assert:type_or_nil(delay, "number")
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("color_fade_out", function(c, duration, delay)
	assert:type(duration, "number")
	assert:type_or_nil(delay, "number")
	c.duration = duration
	c.delay = delay or 0
end)

Concord.component("fade_in_target_alpha", function(c, alpha)
	assert:type(alpha, "number")
	c.value = alpha
end)

Concord.component("remove_blink_on_end")
Concord.component("blink", function(c, dur, count)
	assert:type(dur, "number")
	assert:type(count, "number")
	c.dur = dur
	c.count = count * 2
	c.completed = 0
end)
