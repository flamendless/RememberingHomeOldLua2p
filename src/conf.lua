DEV = false
GIT_COMMIT = ""

local stringx = require("modules.batteries.stringx")
local args = love.arg.parseGameArguments(arg)
for _, v in pairs(args) do
	local arg = stringx.split(v, "=")
	if #arg >= 0 then
		if arg[1] == "--dev" then
			DEV = true
		elseif arg[1] == "--git" then
			GIT_COMMIT = arg[2]
		end
	end
end

if not DEV then
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

	t.window.title = "Remembering Home"
	t.window.width = 1024
	t.window.height = 640
	t.window.resizable = false
	t.window.icon = "res/icon.png"

	t.identity = "rememberinghome"
	t.version = "11.5"

	t.console = true
end
