local Concord = require("modules.concord.concord")

Concord.component("custom_renderer", function(c, str)
	if not (type(str) == "string") then
		error('Assertion failed: type(str) == "string"')
	end
	c.value = str
end)
