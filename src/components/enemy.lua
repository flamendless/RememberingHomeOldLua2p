local Concord = require("modules.concord.concord")

Concord.component("enemy", function(c, enemy_type)
	if not (type(enemy_type) == "string") then
		error('Assertion failed: type(enemy_type) == "string"')
	end
	c.enemy_type = enemy_type
end)
