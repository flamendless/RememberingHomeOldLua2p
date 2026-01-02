local CustomList = {}
CustomList.__mt = {
	__index = CustomList,
}

function CustomList.new()
	return setmetatable({
		size = 0,
	}, CustomList.__mt)
end

function CustomList:add(e)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	local index = self.size + 1
	self[index] = e
	self[e] = index
	self.size = index

	if self.onAdded then
		self:onAdded(e)
	end
	return self
end

function CustomList:remove(e)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	if not self[e] then
		return
	end

	for i = self.size, 1, -1 do
		local e2 = self[i]
		if e == e2 then
			table.remove(self, i)
			self[e] = nil
			self.size = self.size - 1
		end
	end

	if self.onRemoved then
		self:onRemoved(e)
	end
	return self
end

function CustomList:has(e)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	return self[e] and true or false
end

function CustomList:sort(fn)
	if not (type(fn) == "function") then
		error('Assertion failed: type(fn) == "function"')
	end
	table.sort(self, fn)
	return self
end

return setmetatable(CustomList, {
	__call = function()
		return CustomList.new()
	end,
})
