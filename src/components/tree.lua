Concord.component("bg_tree", function(c, is_cover)
	if is_cover then
		assert(type(is_cover) == "boolean", is_cover)
	end
	c.is_cover = is_cover
end)
