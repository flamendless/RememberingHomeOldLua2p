Concord.component("bg_tree", function(c, is_cover)
	assert:type_or_nil(is_cover, "boolean")
	c.is_cover = is_cover
end)
