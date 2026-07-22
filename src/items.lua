local Items = {}

local acquired = {}

local function get_item(id)
	assert(type(id) == "string", id)
	assert(Data.Items[id], "no " .. id .. " in data.items")
	for _, item in ipairs(acquired) do
		if item.id == id then
			return item
		end
	end

	Log.info("Item ID not found. ID: ", id)
end

function Items.add(id)
	assert(type(id) == "string", id)
	assert(Data.Items[id], "no " .. id .. " in data.items")
	if DEV and Items.has(id) then
		Log.warn(id .. " was already added")
	end
	table.insert(acquired, { id = id, equipped = false })
	Log.info("item:", id, "was added")
end

function Items.get_info(id)
	assert(type(id) == "string", id)
	assert(Data.Items[id], id)
	return Data.Items[id]
end

function Items.get_acquired()
	return acquired
end

function Items.has(id)
	assert(type(id) == "string", id)
	assert(Data.Items[id], "no " .. id .. " in data.items")
	local has = get_item(id)
	return has ~= nil
end

function Items.toggle_equip(id)
	assert(type(id) == "string", id)
	assert(Data.Items[id], "no " .. id .. " in data.items")
	local item = get_item(id)
	item.equipped = not item.equipped
end

function Items.is_equipped(id)
	assert(type(id) == "string", id)
	assert(Data.Items[id], "no " .. id .. " in data.items")
	local item = get_item(id)
	assert(item, "failed to get item with id " .. id)
	return item.equipped
end

return Items
