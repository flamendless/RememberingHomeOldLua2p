local Concord = require("modules.concord.concord")

Concord.component("bg_tree", function(c, is_cover)
	if is_cover then
		if not (type(is_cover) == "boolean") then
			error('Assertion failed: type(is_cover) == "boolean"')
		end
	end
	c.is_cover = is_cover
end)
