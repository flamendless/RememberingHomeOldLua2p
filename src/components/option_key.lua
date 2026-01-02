local Concord = require("modules.concord.concord")

Concord.component("option_key", function(c, id, page)
	if not (type(id) == "number") then
		error('Assertion failed: type(id) == "number"')
	end
	if not (type(page) == "number") then
		error('Assertion failed: type(page) == "number"')
	end
	c.id = id
	c.page = page
end)

Concord.component("option_disabled")
