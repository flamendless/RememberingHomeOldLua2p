Concord.component("light_disabled")

Concord.component("light_id", function(c, n)
	assert(type(n) == "number", n)
	c.value = n
end)

Concord.component("light_group", function(c, id)
	assert(type(id) == "string", id)
	c.value = id
end)

Concord.component("light_switch_id", function(c, id)
	assert(type(id) == "string", id)
	c.value = id
end)

Concord.component("point_light", function(c, size)
	assert(type(size) == "number", size)
	c.value = size
	c.orig_value = size
end)

Concord.component("light_dir", function(c, t)
	assert(type(t) == "table", t)
	c.value = t
	c.orig_value = tablex.copy(t)
end)

Concord.component("diffuse", function(c, t)
	assert(type(t) == "table", t)
	c.value = t
	c.orig_value = tablex.copy(t)
end)

Concord.component("light_fading", function(c, amount, dir)
	assert(type(amount) == "number", amount)
	assert((type(dir) == "number" and (dir == -1 or dir == 1)), dir)
	c.amount = amount
	c.dir = dir
end)

Concord.component("d_light_flicker_remove_after")
Concord.component("d_light_flicker_sure_on_after")
Concord.component("d_light_flicker", function(c, during, on_chance, off_chance)
	assert(type(during) == "number", during)
	assert((type(on_chance) == "number" and on_chance >= 0 and on_chance <= 1), on_chance)
	assert((type(off_chance) == "number" and off_chance >= 0 and off_chance <= 1), off_chance)
	c.during = during
	c.on_chance = on_chance
	c.off_chance = off_chance
end)

Concord.component("d_light_flicker_repeat", function(c, count, delay)
	if count then
		assert(type(count) == "number", count)
	end
	if delay then
		assert(type(delay) == "number", delay)
	end
	c.count = count or 0
	c.delay = delay or 0
	c.inf = c.count == -1
end)
