local SystemInfo = {
	data = {},
	options = {},
}

local FILENAME = "system_info.txt"

local function insert_str(src, dest)
	ASSERT(type(src) == "table")
	ASSERT(type(dest) == "table")
	for k, v in pairs(src) do
		local str = string.format("\t%s: %s\n", k, v)
		table.insert(dest, str)
	end
end

function SystemInfo.init()
	Log.info("System information checking...")
	local data = SystemInfo.data
	local system_limits = {}
	local canvas_formats = {}
	local image_formats = {}
	local texture_types = {}
	local supported = {}
	local name, version, vendor, device = love.graphics.getRendererInfo()
	data.game_version = GAME_VERSION
	data.renderer = {
		name = name,
		version = version,
		vendor = vendor,
		device = device
	}
	data.os = love.system.getOS()
	data.processor_count = love.system.getProcessorCount()
	data.limits = love.graphics.getSystemLimits()
	data.canvasformats = love.graphics.getCanvasFormats()
	data.imageformats = love.graphics.getImageFormats()
	data.texturetypes = love.graphics.getTextureTypes()
	data.supported = love.graphics.getSupported()

	insert_str(data.limits, system_limits)
	insert_str(data.canvasformats, canvas_formats)
	insert_str(data.imageformats, image_formats)
	insert_str(data.texturetypes, texture_types)
	insert_str(data.supported, supported)

	local str = {
		string.format("Game Version: %s", data.game_version),
		string.format("OS: %s", data.os),
		string.format("Processor Count: %s", data.processor_count),

		"Renderer Info:",
		string.format("\tName: %s", data.renderer.name),
		string.format("\tVersion: %s", data.renderer.version),
		string.format("\tVendor: %s", data.renderer.vendor),
		string.format("\tDevice: %s", data.renderer.device),

		"System Limits:",
		table.concat(system_limits),

		"Canvas Formats:",
		table.concat(canvas_formats),

		"Image Formats:",
		table.concat(image_formats),

		"Texture Types:",
		table.concat(texture_types),

		"Supported:",
		table.concat(supported),

		"Other Info:",
		string.format("Developer Mode: %s", DEV),
	}

	local to_write = table.concat(str, "\n")
	local content, exists = Utils.file.read(FILENAME)

	if exists then
		SystemInfo.validate_file(content, to_write)
	else
		Utils.file.write(FILENAME, to_write)
		love.filesystem.write(
			"PLEASE_DO_NOT_EDIT_ANY_FILES",
			"Editing any files in this directory will invalidate all your progress"
		)
	end
end

function SystemInfo.validate_file(content, to_write)
	ASSERT(type(content) == "string")
	ASSERT(type(to_write) == "string")
	local same = Utils.hash.compare(content, to_write)
	if same then
		Log.info(FILENAME, "untouched")
	else
		love.filesystem.write(FILENAME, to_write)
		Log.info(FILENAME, "overwritten")
	end
end

function SystemInfo.is_texturesize_compatible(size)
	ASSERT(type(size) == "number")
	return size <= SystemInfo.ata.limits.texturesize
end

return SystemInfo
