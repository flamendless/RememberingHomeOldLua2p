local Log = require("modules.log.log")

local Notes = {}

local list = require("data.notes")
local acquired = {}

local function get_note(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not list[id] then
		error("no " .. id .. " in data.notes")
	end
	for _, note in ipairs(acquired) do
		if note.id == id then
			return note
		end
	end
	return nil
end

function Notes.add(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not list[id] then
		error("no " .. id .. " in data.notes")
	end
	if not (Notes.has(id) == false) then
		error(id .. " was already added")
	end
	table.insert(acquired, tablex.copy(list[id]))
	Log.info("note:", id, "was added")
end

function Notes.get_info(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not list[id] then
		error("Assertion failed: list[id]")
	end
	return list[id]
end

function Notes.has(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not list[id] then
		error("no " .. id .. " in data.notes")
	end
	local has = get_note(id)
	return has ~= nil
end

function Notes.get_acquired()
	return acquired
end

return Notes
