local Cache = {
	entities = {},
	calculated = {},
	resources = {},
}

function Cache.add_entity(e)
	assert(e.__isEntity, e)
	local id = e.id.value
	Cache.entities[id] = e
	Log.info(id, "added to cache")
end

function Cache.has_entity(e)
	return Cache.get_entity(e.id.value) ~= nil
end

function Cache.get_entity(id)
	assert(type(id) == "string", id)
	return Cache.entities[id]
end

function Cache.remove_entity(e)
	assert(e.__isEntity, e)
	local id = e.id.value
	if Cache.entities[id] then
		Cache.entities[id] = nil
		Log.info(id, "removed from cache")
	end
end

function Cache.get(t_id, id)
	assert(type(t_id) == "string", t_id)
	assert(type(id) == "string", id)
	assert(Cache[t_id], t_id .. " is not valid")
	return Cache[t_id][id]
end

function Cache.store(t_id, id, v)
	assert(type(t_id) == "string", t_id)
	assert(type(id) == "string", id)
	assert(v ~= nil, v)
	Cache[t_id][id] = v
end

function Cache.has_resource(id)
	return Cache.resources[id] ~= nil
end

function Cache.clean_resources()
	tablex.clear(Cache.resources)
	assert(#Cache.resources == 0, Cache.resources)
end

function Cache.manage_resources(resources, list, prev_res)
	assert(type(resources) == "table", resources)
	assert(type(list) == "table", list)
	assert(type(prev_res) == "table", prev_res)
	for kind, t in pairs(list) do
		local res = prev_res[kind]
		if res then
			setmetatable(res, nil)

			for i = #t, 1, -1 do
				local id = t[i][1]
				if res[id] then
					Cache.resources[id] = res[id]
					resources[kind][id] = res[id]
					table.remove(list[kind], i)
				end
			end
		end
	end
end

return Cache
