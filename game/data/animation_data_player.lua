local AnimationDataPlayer = {}

AnimationDataPlayer.idle = {
	resource_id = "sheet_player_idle",
	frames = {"1-5", 1, "1-5", 2},
	delay = 0.25,
	rows_count = 2,
	columns_count = 5,
	n_frames = 10,
}

AnimationDataPlayer.walk = {
	resource_id = "sheet_player_walk",
	frames = {"1-4", 1, "1-4", 2},
	delay = 0.1,
	rows_count = 2,
	columns_count = 4,
	n_frames = 8,
}

AnimationDataPlayer.run = {
	resource_id = "sheet_player_run",
	frames = {"1-6", 1},
	delay = 0.1,
	rows_count = 1,
	columns_count = 6,
	n_frames = 6,
}

AnimationDataPlayer.open_door = {
	resource_id = "sheet_player_open_door",
	frames = {"1-7", 1},
	delay = 0.1,
	rows_count = 1,
	columns_count = 7,
	n_frames = 7,
}

AnimationDataPlayer.open_locked_door = {
	resource_id = "sheet_player_open_door",
	frames = {
		"1-7", 1, -- 1-7
		"7-5", 1, -- 8-10
		"5-7", 1, -- 11-13
		"7-1", 1, -- 13-20
	},
	delay = {
		["1-6"] = 0.15,
		["7-8"] = 0.25,
		["9-13"] = 0.075,
		["14-20"] = 0.15,
	},
	rows_count = 1,
	columns_count = 7,
	n_frames = 7,
}

return AnimationDataPlayer
