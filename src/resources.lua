local Log = require("modules.log.log")

local Cache = require("cache")

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

Resources.meta = require("data.resources_list")

function Resources.get_meta(key)
	if not (type(key) == "string") then
		error('Assertion failed: type(key) == "string"')
	end
	if not Resources.meta[key] then
		error(key .. " is invalid")
	end
	local t = tablex.copy(Resources.meta[key])

	t.images = tablex.append({}, t.images, t.array_images)
	if t.array_images then
		tablex.clear(t.array_images)
		t.array_images = nil
	end

	return t
end

function Resources.set_resources(t)
	if not (type(t) == "table") then
		error('Assertion failed: type(t) == "table"')
	end
	tablex.clear(Resources.data)
	if not (#Resources.data == 0) then
		error("Assertion failed: #Resources.data == 0")
	end
	for k, _ in pairs(t) do
		Resources.data[k] = t[k]

		setmetatable(Resources.data[k], mt)
	end
end

function Resources.copy_array_images(resources)
	if not (type(resources) == "table") then
		error('Assertion failed: type(resources) == "table"')
	end
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
