local ListByID = {}

ListByID.__mt = {__index = ListByID}

local function ctor(def)
	local self = setmetatable({}, ListByID.__mt)
	self.id = def.id
	table.insert(def, "list_item")
	table.insert(def, "list_group")
	return self
end

function ListByID:add(entity)
	if entity.list_group.value == self.id then
		table.insert(self, entity)
		return true
	end
	return false
end

function ListByID:remove(entity)
	for i, e in ipairs(self) do
		if e == entity then
			table.remove(self, i)
			return
		end
	end
end

function ListByID:has(entity)
	for _, e in ipairs(self) do
		if e == entity then
			return true
		end
	end
	return false
end

function ListByID:clear()
	for i = #self, 1, -1 do
		self[i] = nil
	end
end

return ctor
