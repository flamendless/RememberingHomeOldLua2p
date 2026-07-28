Concord.component("anim_sync_with", function(c, e_target)
	assert(e_target.__isEntity and e_target:has("animation"), e_target)
	local animation = e_target:get("animation")
	assert(animation.obj, e_target)
	e_target:ensure("key")
	c.key = e_target:get("key").value
end)

Concord.component("anim_sync_data", function(c, c_name, c_props, t)
	assert:type(c_name, "string")
	assert:type(c_props, "table")
	assert:type(t, "table")
	c.c_name = c_name
	c.c_props = c_props
	c.data = t
end)
