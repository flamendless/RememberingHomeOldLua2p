Concord.component("bump")
Concord.component("wall")
Concord.component("ground")
Concord.component("skip_collider_update")

Concord.component("req_col_dir", function(c, dir)
	if not (type(dir) == "number" and (dir == -1 or dir == 1)) then
		error('Assertion failed: type(dir) == "number" and (dir == -1 or dir == 1)')
	end
	c.value = dir
end)

Concord.component("collider", function(c, w, h, filter)
	if type(w) ~= "number" then
		error('Assertion failed: type(w) == "number"')
	end
	if type(h) ~= "number" then
		error('Assertion failed: type(h) == "number"')
	end
	if filter then
		if type(filter) ~= "string" then
			error('Assertion failed: type(filter) == "string"')
		end
	end
	c.w = w
	c.h = h
	c.w_h = w/2
	c.h_h = h/2
	c.is_hit = false
	c.normal = { x = 0, y = 0 }
	c.filter = filter
end)

Concord.component("collider_offset", function(c, ox, oy)
	if type(ox) ~= "number" then
		error('Assertion failed: type(ox) == "number"')
	end
	if type(oy) ~= "number" then
		error('Assertion failed: type(oy) == "number"')
	end
	c.ox = ox
	c.oy = oy
end)

Concord.component("collider_circle", function(c, size, ox, oy)
	if type(size) ~= "number" then
		error('Assertion failed: type(size) == "number"')
	end
	if ox then
		if type(ox) ~= "number" then
			error('Assertion failed: type(ox) == "number"')
		end
	end
	if oy then
		if type(oy) ~= "number" then
			error('Assertion failed: type(oy) == "number"')
		end
	end
	c.size = size
	c.ox = ox
	c.oy = oy
	c.is_hit = false
end)

Concord.component("collide_with", function(c, e)
	if not (e.__isEntity and e.collider) then
		error("Assertion failed: e.__isEntity and e.collider")
	end
	e:ensure("key")
	c.value = e.key.value
end)
