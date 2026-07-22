local defaults = {
	key_map = 1,
	window_mode = 1,
	muted = false,
	volume = 100,
	graphics_quality = "low",
	show_keys = true,
	tutorial = true,
}

local Settings = {
	current = tablex.copy(defaults),
	available_graphics_quality = { "low", "high" },
}

local filename = "user_settings"

function Settings.init()
	local content, exists = Utils.serial.read(filename)
	if exists then
		for k, v in pairs(defaults) do
			if content[k] == nil then
				Log.warn(k, "hardcoded defaults key not in the saved settings file. Resolving by setting value to", v)
				content[k] = v
			end
		end
		Settings.current = content
		pretty.print(Settings.current)
	else
		Settings.create_new()
	end
end

function Settings.create_new()
	Settings.current = tablex.copy(defaults)
	local gl_version = string.sub(Info.data.renderer.version, 1, 3)
	if gl_version == "2.1" then
		Settings.current.graphics_quality = "low"
	else
		Settings.current.graphics_quality = "high"
	end
	Settings.overwrite()
end

function Settings.overwrite()
	Utils.serial.write(filename, Settings.current)
end

function Settings.set(id, value, should_overwrite)
	should_overwrite = should_overwrite or false
	assert(type(id) == "string", id)
	assert(type(value) == "boolean" or type(value) == "number", value)
	assert(type(should_overwrite) == "boolean", should_overwrite)

	local prev = Settings.current[id]
	if prev ~= value then
		Settings.current[id] = value
		Log.info("set", id, "to", value)
		if should_overwrite then
			Settings.overwrite()
		end
	end
end

function Settings.set_from_table(t, should_overwrite)
	assert(type(t) == "table", t)
	assert(type(should_overwrite) == "boolean", should_overwrite)
	for k, v in pairs(t) do
		assert(Settings.current[k] ~= nil, "invalid " .. k .. " key")
		Settings.current[k] = v
		Log.info(string.format("set %s to %s", k, v))
	end

	if should_overwrite then
		Settings.overwrite()
	end
end

return Settings
