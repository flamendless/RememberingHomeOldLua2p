local Data = {
	{
		id = "car",
		x = 781,
		y = 273,
		z = 4,
		dialogue = { "outside", "car" },
		usable_with_item = true,
		not_interactive = true,
	},
	{
		id = "backdoor",
		key = "backdoor",
		x = 485,
		y = 254,
		z = 4,
		req_col_dir = -1,
		is_door_ev = "ev_interact_backdoor",
	},
	{
		id = "frontdoor",
		key = "frontdoor",
		x = 351,
		y = 221,
		z = 4,
		-- dialogue = { "outside", "frontdoor_locked" },
		-- usable_with_item = true,
		-- is_door = true,
		is_door_ev = "ev_interact_frontdoor",
	},
	{
		id = "shed",
		key = "shed",
		x = 32,
		y = 230,
		z = 4,
		req_col_dir = -1,
		interact_box = { x = 79, y = 263, w = 18, h = 62 },
	},
}

return Data
