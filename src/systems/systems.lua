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
	assert(type(id) == "string", id)
	assert(type(bool) == "boolean", bool)
	assert(system_classes[id] ~= nil, id)
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
		assert(type(reversed) == "boolean", reversed)
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
