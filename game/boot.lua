MODE = ""
DEV = false
PROF = false
GAME_VERSION = "0.1.0"
WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 640
GAME_BASE_SIZE = {x = 128, y = 32}

HALF_PI = math.pi * 0.5
TWO_PI = math.pi * 2
T_H_PI = 3 * HALF_PI
CULL_PAD = 32

local args = love.arg.parseGameArguments(arg)
for _, v in pairs(args) do
	if v == "dev" then
		MODE = v
		DEV = true
	elseif v == "prof" then
		MODE = v
		PROF = true
	end
end
print("Running with MODE", MODE)
print("Running with DEV", DEV)

-- if DEV then
-- 	love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. ";modules/?.lua")
-- 	require("jit.p").start("lz")
-- end

if PROF then
	--TODO replace with AppleCake profiler
	PROF_CAPTURE = true
	JPROF = require("modules.jprof.jprof")
end

if DEV then
	function ASSERT(cond, msg)
		if type(cond) == "table" then
			assert(cond ~= nil, msg)
			return
		end
		assert(type(cond) == "boolean", msg)
		if msg then assert(type(msg) == "string", msg) end
		if not cond then error(msg or tostring(cond)) end
	end
	function SASSERT(var, cond, msg)
		if var == nil then return end
		ASSERT(cond, msg)
	end
else
	local noop = function() end
	ASSERT = noop
	SASSERT = noop
end
