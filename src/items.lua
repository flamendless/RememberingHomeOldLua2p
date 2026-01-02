local Log = require("modules.log.log")

local Items = {}

local list = require("data.items")
local acquired = {}

local function get_item(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not list[id] then
		error("no " .. id .. " in data.items")
	end
	for _, item in ipairs(acquired) do
		if item.id == id then
			return item
		end
	end
	return nil
end

function Items.add(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not list[id] then
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
	if not list[id] then
		error("Assertion failed: list[id]")
	end
	return list[id]
end

function Items.get_acquired()
	return acquired
end

function Items.has(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not list[id] then
		error("no " .. id .. " in data.items")
	end
	local has = get_item(id)
	return has ~= nil
end

function Items.toggle_equip(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not list[id] then
		error("no " .. id .. " in data.items")
	end
	local item = get_item(id)
	item.equipped = not item.equipped
end

function Items.is_equipped(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not list[id] then
		error("no " .. id .. " in data.items")
	end
	local item = get_item(id)
	return item.equipped
end

return Items
