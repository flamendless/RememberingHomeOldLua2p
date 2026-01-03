DEV = false

local args = love.arg.parseGameArguments(arg)
for _, v in pairs(args) do
	if v == "--dev" then
		DEV = true
	end
end
print("Running with DEV", DEV)

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

	t.window.title = "Going Home: Revisited"
	t.window.width = 1024
	t.window.height = 640
	t.window.resizable = false
	t.window.icon = "res/icon.png"

	t.identity = "goinghomerevisited"
	t.version = "11.3"

	t.console = true
end
