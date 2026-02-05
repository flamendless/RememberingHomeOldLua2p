local Save = {
	data = {
		splash_done = false,
		intro_done = false,
		outside_intro_done = false,
	},
	checkpoints = {},
	valid_checkpoints = false,
	exists = false,
}

local save_filename = "save_data"
local key_filename = "data_store"

local function validate_checkpoints(data)
	if type(data) ~= "table" then
		error('Assertion failed: type(data) == "table"')
	end
end

function Save.init()
	local content, exists = Utils.file.read(save_filename)
	local key, exists_key = Utils.file.read(key_filename)

	if exists and exists_key then
		local hashed = love.data.hash("sha256", content)
		if key == hashed then
			local data = Utils.serial.de(content)
			Save.data = data
			validate_checkpoints(data)
		else
			local error_msg = string.format(
				"Data integrity is not valid.\n\
				Please do not modify the files: '%s' and '%s'.\n\
				Please delete the files in '%s' and restart the game",
				save_filename,
				key_filename,
				love.filesystem.getSaveDirectory()
			)
			error(error_msg)
		end
	else
		Save.overwrite()
	end

	Save.exists = exists
	Log.info("Save Data:", pretty.string(Save.data))
end

function Save.overwrite()
	local data = Utils.serial.write(save_filename, Save.data)
	local hashed = love.data.hash("sha256", data)
	Utils.file.write(key_filename, hashed)
	Log.info("Save overwritten")
end

function Save.toggle_flag(id, should_overwrite)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	if not (Save.data[id] ~= nil) then
		error("Assertion failed: Save.data[id] ~= nil")
	end
	if should_overwrite then
		if type(should_overwrite) ~= "boolean" then
			error('Assertion failed: type(should_overwrite) == "boolean"')
		end
	end
	Save.data[id] = not Save.data[id]
	if should_overwrite then
		Save.overwrite()
	end
end

function Save.set_flag(id, value, should_overwrite)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	if not (Save.data[id] ~= nil) then
		error("Assertion failed: Save.data[id] ~= nil")
	end
	if type(value) ~= "boolean" then
		error('Assertion failed: type(value) == "boolean"')
	end
	if should_overwrite then
		if type(should_overwrite) ~= "boolean" then
			error('Assertion failed: type(should_overwrite) == "boolean"')
		end
	end
	Save.data[id] = value
	if should_overwrite then
		Save.overwrite()
	end
end

return Save
