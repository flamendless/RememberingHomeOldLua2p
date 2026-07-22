Concord.component("auto_scale", function(c, tw, th, is_proportion, is_floored)
	assert(type(tw) == "number", tw)
	assert(type(th) == "number", th)
	if is_proportion then
		assert(type(is_proportion) == "boolean", is_proportion)
	end
	if is_floored then
		assert(type(is_floored) == "boolean", is_floored)
	end
	c.tw = tw
	c.th = th
	c.is_proportion = is_proportion or false
	c.is_floored = is_floored or false
end)
