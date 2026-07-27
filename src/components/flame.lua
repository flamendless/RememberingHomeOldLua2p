Concord.component("flame")

Concord.component("flame_health", function(c, max_health, consumption_rate)
	assert(type(max_health) == "number", max_health)
	assert(type(consumption_rate) == "number", consumption_rate)
	c.health = max_health
	c.max_health = max_health
	c.consumption_rate = consumption_rate
end)

Concord.component("flame_flicker", function(c)
	c.since_flicker = 0
	c.next_threshold = love.math.random(3, 7)
	c.flicker_timer = 0
end)

Concord.component("flame_windable", function(c, blow_out_min_strength, blow_out_chance_scale)
	c.offset = 0
	c.offset_target = 0
	c.flicker_timer = 0
	c.extinguished = false
	c.blow_out_min_strength = blow_out_min_strength or 10
	c.blow_out_chance_scale = blow_out_chance_scale or 0.04
end)

Concord.component("flame_anchor", function(c, base_x, base_y, dir)
	c.base_x = base_x or 0
	c.base_y = base_y or 0
	c.dir = dir or 1
end)

Concord.component("flame_suppressed")

Concord.component("candle", function(c, e_flame)
	assert(e_flame.__isEntity, e_flame)
	c.e_flame = e_flame
	c.is_extinguished = false
end)
