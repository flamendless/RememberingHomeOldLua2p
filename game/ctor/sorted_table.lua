local SortedTable = {}

SortedTable.__mt = {__index = SortedTable}

local function sort_by_id(a, b)
	return a.layer.n < b.layer.n
end

local function ctor(def)
	local self = setmetatable({}, SortedTable.__mt)
	self.layer_id = def.layer
	table.insert(def, "layer")

	return self
end

function SortedTable:add(entity)
	if entity.layer.id == self.layer_id then
		table.insert(self, entity)
		sort.insertion_sort(self, sort_by_id)
		return true
	end
	return false
end

function SortedTable:remove(entity)
	for i, e in ipairs(self) do
		if e == entity then
			table.remove(self, i)
			return
		end
	end
end

function SortedTable:has(entity)
	for _, e in ipairs(self) do
		if e == entity then
			return true
		end
	end
	return false
end

function SortedTable:clear()
	for i = #self, 1, -1 do
		self[i] = nil
	end
end

return ctor
