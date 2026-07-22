local Notes = {}

local acquired = {}

local function get_note(id)
	assert(type(id) == "string", id)
	assert(Data.Notes[id], "no " .. id .. " in data.notes")
	for _, note in ipairs(acquired) do
		if note.id == id then
			return note
		end
	end
	return nil
end

function Notes.add(id)
	assert(type(id) == "string", id)
	assert(Data.Notes[id], "no " .. id .. " in data.notes")
	assert(not Notes.has(id), id .. " was already added")
	table.insert(acquired, tablex.copy(Data.Notes[id]))
	Log.info("note:", id, "was added")
end

function Notes.get_info(id)
	assert(type(id) == "string", id)
	assert(Data.Notes[id], id)
	return Data.Notes[id]
end

function Notes.has(id)
	assert(type(id) == "string", id)
	assert(Data.Notes[id], "no " .. id .. " in data.notes")
	local has = get_note(id)
	return has ~= nil
end

function Notes.get_acquired()
	return acquired
end

return Notes
