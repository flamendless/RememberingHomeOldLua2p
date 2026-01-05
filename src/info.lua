local Info = {
	data = {},
	options = {},
}

local filename = "info.txt"

local function insert_str(src, dest)
	if not (type(src) == "table") then
		error('Assertion failed: type(src) == "table"')
	end
	if not (type(dest) == "table") then
		error('Assertion failed: type(dest) == "table"')
	end
	for k, v in pairs(src) do
		local str = string.format("\t%s: %s\n", k, v)
		table.insert(dest, str)
	end
end

function Info.init()
	Log.info("System information checking...")
	local data = Info.data
	local system_limits = {}
	local canvas_formats = {}
	local image_formats = {}
	local texture_types = {}
	local supported = {}
	local graphics = {}
	local name, version, vendor, device = love.graphics.getRendererInfo()
	data.renderer = {
		name = name,
		version = version,
		vendor = vendor,
		device = device,
	}
	data.info_os = love.system.getOS()
	data.processor_count = love.system.getProcessorCount()
	data.game_version = "0.0.1"
	data.git_version = GIT_COMMIT
	data.limits = love.graphics.getSystemLimits()
	data.canvasformats = love.graphics.getCanvasFormats()
	data.imageformats = love.graphics.getImageFormats()
	data.texturetypes = love.graphics.getTextureTypes()
	data.supported = love.graphics.getSupported()

	local dw, dh = love.window.getDesktopDimensions()
	local gw, gh = love.graphics.getDimensions()
	data.graphics = {
		desktop_width = dw,
		desktop_height = dh,
		dpi = love.graphics.getDPIScale(),
		game_width = gw,
		game_height = gh,
	}

	insert_str(data.limits, system_limits)
	insert_str(data.canvasformats, canvas_formats)
	insert_str(data.imageformats, image_formats)
	insert_str(data.texturetypes, texture_types)
	insert_str(data.supported, supported)
	insert_str(data.graphics, graphics)

	local str = {
		string.format("Game Version: %s", data.game_version),
		string.format("Git Commit Version: %s", data.git_version),
		string.format("OS: %s", data.info_os),
		string.format("Processor Count: %s", data.processor_count),

		"Renderer Info:",
		string.format("\tName: %s", data.renderer.name),
		string.format("\tVersion: %s", data.renderer.version),
		string.format("\tVendor: %s", data.renderer.vendor),
		string.format("\tDevice: %s", data.renderer.device),
		"\n",

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

		"Graphics:",
		table.concat(graphics),

		"Other Info:",
		string.format("Developer Mode: %s", true),
	}

	local to_write = table.concat(str, "\n")
	local content, exists = Utils.file.read(filename)

	if DEV then
		print(to_write)
	end

	if exists then
		Info.validate_file(content, to_write)
	else
		Utils.file.write(filename, to_write)
		love.filesystem.write(
			"PLEASE_DO_NOT_EDIT_ANY_FILES",
			"Editing any files in this directory will invalidate all your progress"
		)
	end
end

function Info.validate_file(content, to_write)
	local same = Utils.hash.compare(content, to_write)
	if same then
		Log.info(filename, "untouched")
	else
		love.filesystem.write(filename, to_write)
		Log.info(filename, "overwritten")
	end
end

function Info.is_texturesize_compatible(size)
	local max_size = Info.data.limits.texturesize
	return size <= max_size
end

return Info
