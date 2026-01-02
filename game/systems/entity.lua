local Concord = require("modules.concord.concord")

local Entity = Concord.system()

function Entity:hide_entity(e)
	if not (e.__isEntity) then error("Assertion failed: e.__isEntity") end
	e:give("hidden")
end

function Entity:destroy_entity(e)
	if not (e.__isEntity) then error("Assertion failed: e.__isEntity") end
	e:destroy()
end

function Entity:toggle_component(e, prop, bool)
	if not (e.__isEntity) then error("Assertion failed: e.__isEntity") end
	if not (type(prop) == "string") then error("Assertion failed: type(prop) == \"string\"") end
	if not (type(bool) == "boolean") then error("Assertion failed: type(bool) == \"boolean\"") end
	if bool then
		e:give(prop)
	else
		e:remove(prop)
	end
end


return Entity
