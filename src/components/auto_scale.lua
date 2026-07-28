Concord.component("auto_scale", function(c, tw, th, is_proportion, is_floored)
	assert:type(tw, "number")
	assert:type(th, "number")
	assert:type_or_nil(is_proportion, "boolean")
	assert:type_or_nil(is_floored, "boolean")
	c.tw = tw
	c.th = th
	c.is_proportion = is_proportion or false
	c.is_floored = is_floored or false
end)
