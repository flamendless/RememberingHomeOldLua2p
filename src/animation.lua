local AnimationData = require("data.animation_data")
local AnimationSyncData = require("data.animation_sync_data")

local Animation = {}

function Animation.get_multi_by_id(id, tbl)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not (type(tbl) == "table") then
		error('Assertion failed: type(tbl) == "table"')
	end
	if not AnimationData[id] then
		error("Assertion failed: AnimationData[id]")
	end
	local data, mods = {}, {}
	for _, v in ipairs(tbl) do
		if not (type(v) == "string") then
			error('Assertion failed: type(v) == "string"')
		end
		data[v] = tablex.copy(AnimationData[id][v])
		mods[v] = { v .. "_left", "flipH" }
	end
	return data, mods
end

function Animation.get(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not AnimationData[id] then
		error("Assertion failed: AnimationData[id]")
	end
	return tablex.copy(AnimationData[id])
end

function Animation.get_sync_data(id)
	if not (type(id) == "string") then
		error('Assertion failed: type(id) == "string"')
	end
	if not AnimationSyncData[id] then
		error("Assertion failed: AnimationSyncData[id]")
	end
	return tablex.copy(AnimationSyncData[id])
end

return Animation
