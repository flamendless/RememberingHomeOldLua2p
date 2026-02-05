local Systems = Concord.system()

local classes = { "dialogues", "inventory", "notes" }
local system_classes = {}

function Systems:init(world)
	self.world = world
	for _, class in ipairs(classes) do
		system_classes[class] = ECS.get_system_class(class)
	end
end

function Systems:set_system_to(id, bool)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	if type(bool) ~= "boolean" then
		error('Assertion failed: type(bool) == "boolean"')
	end
	if system_classes[id] == nil then
		error("Assertion failed: system_classes[id] ~= nil")
	end
	local sys = self.world:getSystem(system_classes[id])
	sys:setEnabled(bool)
end

function Systems:dialogue_to_inventory()
	self:set_system_to("dialogues", false)
	self:set_system_to("inventory", true)
	Log.trace("dialogue_to_inventory")
end

function Systems:inventory_to_notes(reversed)
	if reversed then
		if type(reversed) ~= "boolean" then
			error('Assertion failed: type(reversed) == "boolean"')
		end
	end
	if not reversed then
		self:set_system_to("inventory", false)
		self:set_system_to("notes", true)
	else
		self:set_system_to("inventory", true)
		self:set_system_to("notes", false)
	end
	Log.trace("inventory_to_notes")
end

return Systems
