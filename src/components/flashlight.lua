Concord.component("flashlight")
Concord.component("flashlight_light")

Concord.component("battery", function(c, pct)
	if pct then
		assert((type(pct) == "number" and pct > 0 and pct <= 100), pct)
	end
	c.pct = pct
	c.orig_pct = pct
end)

local c_bs = Concord.component("battery_state", function(c, state)
	c.value = state
end)

function c_bs:set(state)
	self.value = state
end

Concord.component("fl_spawn_offset", function(c, x, y)
	if x then
		assert(type(x) == "number", x)
	end
	if y then
		assert(type(y) == "number", y)
	end

	c.x = x or 0
	c.y = y or 0
	c.dy = 0
	c.orig_x = c.x
	c.orig_y = c.y
	c.orig_dy = c.dy
end)
