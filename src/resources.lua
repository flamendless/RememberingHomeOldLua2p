local Resources = {
	meta = {},
	data = {},
}

local mt = {}
mt.__index = function(t, i)
	local id
	for k, v in pairs(Resources.data) do
		if t == v then
			id = k
			break
		end
	end
	error(i .. " is invalid key for Resources:" .. id)
end

Resources.meta = Data.ResourcesList

function Resources.get_meta(key)
	assert(type(key) == "string", key)
	assert(Resources.meta[key], key .. " is invalid")
	local t = tablex.copy(Resources.meta[key])

	t.images = tablex.append({}, t.images, t.array_images)
	if t.array_images then
		tablex.clear(t.array_images)
		t.array_images = nil
	end

	return t
end

function Resources.set_resources(t)
	assert(type(t) == "table", t)
	tablex.clear(Resources.data)
	assert(#Resources.data == 0, Resources.data)
	for k, _ in pairs(t) do
		Resources.data[k] = t[k]

		setmetatable(Resources.data[k], mt)
	end
end

function Resources.copy_array_images(resources)
	assert(type(resources) == "table", resources)
	for k, v in pairs(resources.array_images) do
		resources.images[k] = v
	end
end

function Resources.clean()
	for k, t in pairs(Resources.data) do
		for name, _ in pairs(t) do
			if not Cache.has_resource(name) then
				Resources.data[k][name]:release()
				Resources.data[k][name] = nil
				Log.trace("Cleaned:", k, name)
			else
				Log.trace("Cached, skipping:", k, name)
			end
		end
		Resources.data[k] = nil
	end

	Cache.clean_resources()
end

return Resources
