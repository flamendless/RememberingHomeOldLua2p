Concord.component("bump")
Concord.component("wall")
Concord.component("ground")
Concord.component("skip_collider_update")

Concord.component("req_col_dir", function(c, dir)
	assert((type(dir) == "number" and (dir == -1 or dir == 1)), dir)
	c.value = dir
end)

Concord.component("collider", function(c, w, h, filter)
	assert:type(w, "number")
	assert:type(h, "number")
	assert:type_or_nil(filter, "string")
	c.w = w
	c.h = h
	c.w_h = w/2
	c.h_h = h/2
	c.is_hit = false
	c.normal = { x = 0, y = 0 }
	c.filter = filter
end)

Concord.component("collider_offset", function(c, ox, oy)
	assert:type(ox, "number")
	assert:type(oy, "number")
	c.ox = ox
	c.oy = oy
end)

Concord.component("collider_circle", function(c, size, ox, oy)
	assert:type(size, "number")
	assert:type_or_nil(ox, "number")
	assert:type_or_nil(oy, "number")
	c.size = size
	c.ox = ox
	c.oy = oy
	c.is_hit = false
end)

Concord.component("collide_with", function(c, e)
	assert((e.__isEntity and e:has("collider")), e)
	e:ensure("key")
	c.value = e:get("key").value
end)
