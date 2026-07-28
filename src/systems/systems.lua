local Systems = Concord.system()

local classes = {
	Enums.ui_system.dialogues,
	Enums.ui_system.inventory,
	Enums.ui_system.notes,
}
local system_classes = {}

function Systems:init(world)
	self.world = world
	for _, class in ipairs(classes) do
		system_classes[class] = ECS.get_system_class(class)
	end
end

function Systems:set_system_to(id, bool)
	assert(Enums.ui_system[id], id)
	assert:type(bool, "boolean")
	assert(system_classes[id] ~= nil, id)
	local sys = self.world:getSystem(system_classes[id])
	sys:setEnabled(bool)
end

function Systems:dialogue_to_inventory()
	self:set_system_to(Enums.ui_system.dialogues, false)
	self:set_system_to(Enums.ui_system.inventory, true)
	Log.trace("dialogue_to_inventory")
end

function Systems:inventory_to_notes(reversed)
	assert:type_or_nil(reversed, "boolean")
	if not reversed then
		self:set_system_to(Enums.ui_system.inventory, false)
		self:set_system_to(Enums.ui_system.notes, true)
	else
		self:set_system_to(Enums.ui_system.inventory, true)
		self:set_system_to(Enums.ui_system.notes, false)
	end
	Log.trace("inventory_to_notes")
end

return Systems
