Concord.component("anim_sync_with", function(c, e_target)
	assert((e_target.__isEntity and e_target.animation and e_target.current_frame), e_target)
	e_target:ensure("key")
	c.key = e_target.key.value
end)

Concord.component("anim_sync_data", function(c, c_name, c_props, t)
	assert(type(c_name) == "string", c_name)
	assert(type(c_props) == "table", c_props)
	assert(type(t) == "table", t)
	c.c_name = c_name
	c.c_props = c_props
	c.data = t
end)
