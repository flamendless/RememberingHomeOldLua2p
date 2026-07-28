Concord.component("hover_emit")

Concord.component("hoverable", function(c)
	c.prev_hovered = false
	c.is_hovered = false
end)

Concord.component("hover_change_color", function(c, target, step)
	assert:type(target, "table")
	assert:type(step, "number")
	c.target = target
	c.step = step
end)

Concord.component("hover_change_scale", function(c, target, step)
	assert:type(target, "number")
	assert:type(step, "number")
	c.target = target
	c.step = step
end)
