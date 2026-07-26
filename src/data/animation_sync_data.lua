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

local function wick_lit(x, y)
	return { x = x, y = y, power = 1 }
end

local function wick_unlit(x, y)
	return { x = x, y = y, power = 0 }
end

AnimationDataSync.lighter = {
	open_lighter = {
		[1] = wick_unlit(8, -8),
		[2] = wick_unlit(12, -12),
		[3] = wick_unlit(16, -14),
		[4] = wick_unlit(18, -16),
		[5] = wick_unlit(20, -18),
		[6] = wick_unlit(22, -19),
		[7] = wick_unlit(24, -20),
		[8] = wick_lit(26, -20),
		[9] = wick_lit(26, -20),
		[10] = wick_lit(26, -20),
		[11] = wick_lit(26, -20),
	},
	close_lighter = {
		[1] = wick_lit(26, -20),
		[2] = wick_lit(26, -20),
		[3] = wick_lit(24, -20),
		[4] = wick_lit(22, -19),
		[5] = wick_unlit(20, -18),
		[6] = wick_unlit(18, -16),
		[7] = wick_unlit(16, -14),
		[8] = wick_unlit(12, -12),
		[9] = wick_unlit(8, -8),
		[10] = wick_unlit(6, -6),
		[11] = wick_unlit(4, -4),
	},
}

return AnimationDataSync
