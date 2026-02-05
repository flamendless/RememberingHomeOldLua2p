Concord.component("hover_emit")

Concord.component("hoverable", function(c)
	c.prev_hovered = false
	c.is_hovered = false
end)

Concord.component("hover_change_color", function(c, target, step)
	if type(target) ~= "table" then
		error('Assertion failed: type(target) == "table"')
	end
	if type(step) ~= "number" then
		error('Assertion failed: type(step) == "number"')
	end
	c.target = target
	c.step = step
end)

Concord.component("hover_change_scale", function(c, target, step)
	if type(target) ~= "number" then
		error('Assertion failed: type(target) == "number"')
	end
	if type(step) ~= "number" then
		error('Assertion failed: type(step) == "number"')
	end
	c.target = target
	c.step = step
end)
