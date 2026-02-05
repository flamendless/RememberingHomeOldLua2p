local Cache = {
	entities = {},
	calculated = {},
	resources = {},
}

function Cache.add_entity(e)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	local id = e.id.value
	Cache.entities[id] = e
	Log.info(id, "added to cache")
end

function Cache.has_entity(e)
	return Cache.get_entity(e.id.value) ~= nil
end

function Cache.get_entity(id)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	return Cache.entities[id]
end

function Cache.remove_entity(e)
	if not e.__isEntity then
		error("Assertion failed: e.__isEntity")
	end
	local id = e.id.value
	if Cache.entities[id] then
		Cache.entities[id] = nil
		Log.info(id, "removed from cache")
	end
end

function Cache.get(t_id, id)
	if type(t_id) ~= "string" then
		error('Assertion failed: type(t_id) == "string"')
	end
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	if not Cache[t_id] then
		error(t_id .. " is not valid")
	end
	return Cache[t_id][id]
end

function Cache.store(t_id, id, v)
	if type(t_id) ~= "string" then
		error('Assertion failed: type(t_id) == "string"')
	end
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	if v == nil then
		error("Assertion failed: v ~= nil")
	end
	Cache[t_id][id] = v
end

function Cache.has_resource(id)
	return Cache.resources[id] ~= nil
end

function Cache.clean_resources()
	tablex.clear(Cache.resources)
	if #Cache.resources ~= 0 then
		error("Assertion failed: #Cache.resources == 0")
	end
end

function Cache.manage_resources(resources, list, prev_res)
	if type(resources) ~= "table" then
		error('Assertion failed: type(resources) == "table"')
	end
	if type(list) ~= "table" then
		error('Assertion failed: type(list) == "table"')
	end
	if type(prev_res) ~= "table" then
		error('Assertion failed: type(prev_res) == "table"')
	end
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
