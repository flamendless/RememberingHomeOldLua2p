Concord.component("light_disabled")

Concord.component("light_id", function(c, n)
	if type(n) ~= "number" then
		error('Assertion failed: type(n) == "number"')
	end
	c.value = n
end)

Concord.component("light_group", function(c, id)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	c.value = id
end)

Concord.component("light_switch_id", function(c, id)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	c.value = id
end)

Concord.component("point_light", function(c, size)
	if type(size) ~= "number" then
		error('Assertion failed: type(size) == "number"')
	end
	c.value = size
	c.orig_value = size
end)

Concord.component("light_dir", function(c, t)
	if type(t) ~= "table" then
		error('Assertion failed: type(t) == "table"')
	end
	c.value = t
	c.orig_value = tablex.copy(t)
end)

Concord.component("diffuse", function(c, t)
	if type(t) ~= "table" then
		error('Assertion failed: type(t) == "table"')
	end
	c.value = t
	c.orig_value = tablex.copy(t)
end)

Concord.component("light_fading", function(c, amount, dir)
	if type(amount) ~= "number" then
		error('Assertion failed: type(amount) == "number"')
	end
	if not (type(dir) == "number" and (dir == -1 or dir == 1)) then
		error('Assertion failed: type(dir) == "number" and (dir == -1 or dir == 1)')
	end
	c.amount = amount
	c.dir = dir
end)

Concord.component("d_light_flicker_remove_after")
Concord.component("d_light_flicker_sure_on_after")
Concord.component("d_light_flicker", function(c, during, on_chance, off_chance)
	if type(during) ~= "number" then
		error('Assertion failed: type(during) == "number"')
	end
	if not (type(on_chance) == "number" and on_chance >= 0 and on_chance <= 1) then
		error('Assertion failed: type(on_chance) == "number" and on_chance >= 0 and on_chance <= 1')
	end
	if not (type(off_chance) == "number" and off_chance >= 0 and off_chance <= 1) then
		error('Assertion failed: type(off_chance) == "number" and off_chance >= 0 and off_chance <= 1')
	end
	c.during = during
	c.on_chance = on_chance
	c.off_chance = off_chance
end)

Concord.component("d_light_flicker_repeat", function(c, count, delay)
	if count then
		if type(count) ~= "number" then
			error('Assertion failed: type(count) == "number"')
		end
	end
	if delay then
		if type(delay) ~= "number" then
			error('Assertion failed: type(delay) == "number"')
		end
	end
	c.count = count or 0
	c.delay = delay or 0
	c.inf = c.count == -1
end)
