local splash = require("test.scenarios.splash")
local menu = require("test.scenarios.menu")
local intro = require("test.scenarios.intro")
local outside_tutorial = require("test.scenarios.outside_tutorial")

local steps = {}
for _, v in ipairs(splash.steps) do table.insert(steps, v) end
for _, v in ipairs(menu.steps) do table.insert(steps, v) end
for _, v in ipairs(intro.steps) do table.insert(steps, v) end
for _, v in ipairs(outside_tutorial.steps) do table.insert(steps, v) end

assert(#steps > 0, #steps)

return {
	name = "all",
	state = Enums.game_state.Splash,
	steps = steps,
}
