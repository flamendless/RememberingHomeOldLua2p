local Animation = {}

function Animation.get_multi_by_id(id, tbl)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	if type(tbl) ~= "table" then
		error('Assertion failed: type(tbl) == "table"')
	end
	if not Data.AnimationData[id] then
		error("Assertion failed: Data.animation_data[id]")
	end
	local data, mods = {}, {}
	for _, v in ipairs(tbl) do
		if type(v) ~= "string" then
			error('Assertion failed: type(v) == "string"')
		end
		data[v] = tablex.copy(Data.AnimationData[id][v])
		mods[v] = { v .. "_left", "flipH" }
	end
	return data, mods
end

function Animation.get(id)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	if not Data.AnimationData[id] then
		error("Assertion failed: Data.animation_data[id]")
	end
	return tablex.copy(Data.AnimationData[id])
end

function Animation.get_sync_data(id)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	if not Data.AnimationSyncData[id] then
		error("Assertion failed: Data.animation_sync_data[id]")
	end
	return tablex.copy(Data.AnimationSyncData[id])
end

return Animation
