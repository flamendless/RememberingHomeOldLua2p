Concord.component("anim_sync_with", function(c, e_target)
	if not (e_target.__isEntity and e_target.animation and e_target.current_frame) then
		error("Assertion failed: e_target.__isEntity and e_target.animation and e_target.current_frame")
	end
	e_target:ensure("key")
	c.key = e_target.key.value
end)

Concord.component("anim_sync_data", function(c, c_name, c_props, t)
	if not (type(c_name) == "string") then
		error('Assertion failed: type(c_name) == "string"')
	end
	if not (type(c_props) == "table") then
		error('Assertion failed: type(c_props) == "table"')
	end
	if not (type(t) == "table") then
		error('Assertion failed: type(t) == "table"')
	end
	c.c_name = c_name
	c.c_props = c_props
	c.data = t
end)
