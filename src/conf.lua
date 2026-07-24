DEV = false
PROF = false
GIT_COMMIT = ""
TEST = {
	mode = false,
	scenario = nil,
	seed = nil,
	timeout = 120,
}
GAME_SPEED_MULT = 1

local stringx = require("modules.batteries.stringx")
local args = love.arg.parseGameArguments(arg)
for _, v in pairs(args) do
	local arg = stringx.split(v, "=")
	if #arg >= 0 then
		if arg[1] == "--dev" then
			DEV = true
		elseif arg[1] == "--prof" then
			PROF = true
		elseif arg[1] == "--git" then
			GIT_COMMIT = arg[2]
		elseif arg[1] == "--test" then
			TEST.mode = true
			TEST.scenario = arg[2] or "boot_to_outside"
		elseif arg[1] == "--speed" then
			GAME_SPEED_MULT = tonumber(arg[2]) or GAME_SPEED_MULT
		elseif arg[1] == "--seed" then
			TEST.seed = tonumber(arg[2])
		elseif arg[1] == "--test-timeout" then
			TEST.timeout = tonumber(arg[2]) or TEST.timeout
		end
	end
end

if TEST.mode then
	DEV = false
	if TEST.scenario and GAME_SPEED_MULT == 1 then
		GAME_SPEED_MULT = 20
	end
end

if not DEV and not TEST.mode then
	--INFO: (Brandon) - hack for Mac OS
	local exeDir = love.filesystem.getSourceBaseDirectory()
	package.path = exeDir .. "/?.lua;" .. package.path

	local ok, mod = pcall(require, "lbconfig")
	print("lbconfig", ok, mod)
	if ok then
		if mod.config == "dev" then
			DEV = true
		end
	end
end

print("Running with DEV", DEV)
print("             COMMIT", GIT_COMMIT)
if TEST.mode then
	print("             TEST", TEST.scenario, "speed", GAME_SPEED_MULT)
end

function love.conf(t)
	t.modules.audio = true
	t.modules.data = true
	t.modules.event = true
	t.modules.font = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = false
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = false
	t.modules.sound = true
	t.modules.system = true
	t.modules.thread = true
	t.modules.timer = true
	t.modules.touch = false
	t.modules.video = false
	t.modules.window = true

	local prefix = ""
	if TEST.mode then
		prefix = "[TEST] "
	elseif DEV then
		prefix = "[DEV] "
	end
	if PROF then prefix = prefix .. "[PROF] " end

	t.window.title = prefix .. "Remembering Home"
	t.window.width = 1024
	t.window.height = 640
	t.window.resizable = false
	t.window.icon = "res/icon.png"

	t.identity = TEST.mode and "rememberinghome_test" or "rememberinghome"
	t.version = "11.5"

	if DEV or PROF or TEST.mode then
		t.console = true
	end
end
