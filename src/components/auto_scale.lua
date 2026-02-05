Concord.component("auto_scale", function(c, tw, th, is_proportion, is_floored)
	if type(tw) ~= "number" then
		error('Assertion failed: type(tw) == "number"')
	end
	if type(th) ~= "number" then
		error('Assertion failed: type(th) == "number"')
	end
	if is_proportion then
		if type(is_proportion) ~= "boolean" then
			error('Assertion failed: type(is_proportion) == "boolean"')
		end
	end
	if is_floored then
		if type(is_floored) ~= "boolean" then
			error('Assertion failed: type(is_floored) == "boolean"')
		end
	end
	c.tw = tw
	c.th = th
	c.is_proportion = is_proportion or false
	c.is_floored = is_floored or false
end)
