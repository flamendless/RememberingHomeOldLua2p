local AnimationDataSync = {}

local x_idle_walk = 0
local x_run = 0
local by1 = -11
local by2 = -12

AnimationDataSync.flashlight = {
	idle = {
		[1] = { x = x_idle_walk, y = by1, dy = 0 }, --38, 17
		[6] = { x = x_idle_walk, y = by2, dy = 0 }, --38, 16
	},
	walk = {
		[1] = { x = x_idle_walk, y = by1, dy = 0 },
		[2] = { x = x_idle_walk, y = by2, dy = 0 },
		[4] = { x = x_idle_walk, y = by1, dy = 0 },
		[6] = { x = x_idle_walk, y = by2, dy = 0 },
		[8] = { x = x_idle_walk, y = by1, dy = 0 },
	},
	run = {
		[1] = { x = x_run, y = -10, dy = 0 }, --40, 19
		[3] = { x = x_run, y = -9, dy = 0.1 }, --40, 20
		[6] = { x = x_run, y = -10, dy = 0 },
	},
}

return AnimationDataSync
