local Items = {}

local acquired = {}

local function get_item(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not Data.Items[id] then
		error("no " .. id .. " in data.items")
	end
	for _, item in ipairs(acquired) do
		if item.id == id then
			return item
		end
	end

	Log.info("Item ID not found. ID: ", id)
end

function Items.add(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not Data.Items[id] then
		error("no " .. id .. " in data.items")
	end
	if not (Items.has(id) == false) then
		error(id .. " was already added")
	end
	table.insert(acquired, { id = id, equipped = false })
	Log.info("item:", id, "was added")
end

function Items.get_info(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not Data.Items[id] then
		error("Assertion failed: Data.items[id]")
	end
	return Data.Items[id]
end

function Items.get_acquired()
	return acquired
end

function Items.has(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not Data.Items[id] then
		error("no " .. id .. " in data.items")
	end
	local has = get_item(id)
	return has ~= nil
end

function Items.toggle_equip(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not Data.Items[id] then
		error("no " .. id .. " in data.items")
	end
	local item = get_item(id)
	item.equipped = not item.equipped
end

function Items.is_equipped(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not Data.Items[id] then
		error("no " .. id .. " in data.items")
	end
	local item = get_item(id)
	return item.equipped
end

return Items
