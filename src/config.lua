local Semver = require("modules.semver.semver")

local Config = {}

Config.this_version = "0.0.1"
Config.this_semver = Semver(Config.this_version)
Config.current_wm = 1
Config.window_modes = { { height = 640, width = 1024 } }
Config.window_modes_str = { "1024x640" }

function Config.getWindowMode()
	return Config.window_modes[Config.current_wm]
end

return Config
