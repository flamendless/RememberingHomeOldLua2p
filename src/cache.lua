local Cache = {
	entities = {},
	calculated = {},
	resources = {},
}

function Cache.add_entity(e)
	assert(e.__isEntity, e)
	local id = e:get("id").value
	Cache.entities[id] = e
	Log.info(id, "added to cache")
end

function Cache.has_entity(e)
	return Cache.get_entity(e:get("id").value) ~= nil
end

function Cache.get_entity(id)
	assert:type(id, "string")
	return Cache.entities[id]
end

function Cache.remove_entity(e)
	assert(e.__isEntity, e)
	local id = e:get("id").value
	if Cache.entities[id] then
		Cache.entities[id] = nil
		Log.info(id, "removed from cache")
	end
end

function Cache.get(t_id, id)
	assert:type(t_id, "string")
	assert:type(id, "string")
	assert(Cache[t_id], t_id .. " is not valid")
	return Cache[t_id][id]
end

function Cache.store(t_id, id, v)
	assert:type(t_id, "string")
	assert:type(id, "string")
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
	assert:type(resources, "table")
	assert:type(list, "table")
	assert:type(prev_res, "table")
	for kind, t in pairs(list) do
		local res = prev_res[kind]
		local array_res = (kind == "images") and prev_res.array_images or nil
		if res or array_res then
			if res then
				setmetatable(res, nil)
			end
			if array_res then
				setmetatable(array_res, nil)
			end

			for i = #t, 1, -1 do
				local id = t[i][1]
				local cached = (res and res[id]) or (array_res and array_res[id])
				if cached then
					Cache.resources[id] = cached
					resources[kind][id] = cached
					table.remove(list[kind], i)
				end
			end
		end
	end
end

return Cache
