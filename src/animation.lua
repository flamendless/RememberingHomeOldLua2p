local Animation = {}

function Animation.get_multi_by_id(id, tbl)
	assert(type(id) == "string", id)
	assert(type(tbl) == "table", tbl)
	assert(Data.AnimationData[id], id)
	local data, mods = {}, {}
	for _, v in ipairs(tbl) do
		assert(type(v) == "string", v)
		data[v] = tablex.copy(Data.AnimationData[id][v])
		mods[v] = { v .. "_left", "flipH" }
	end
	return data, mods
end

function Animation.get(id)
	assert(type(id) == "string", id)
	assert(Data.AnimationData[id], id)
	return tablex.copy(Data.AnimationData[id])
end

function Animation.get_sync_data(id)
	assert(type(id) == "string", id)
	assert(Data.AnimationSyncData[id], id)
	return tablex.copy(Data.AnimationSyncData[id])
end

return Animation
