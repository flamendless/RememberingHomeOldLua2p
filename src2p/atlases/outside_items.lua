local Data = {
	{
		id = "car",
		x = 729, y = 273, z = 4,
		dialogue = {"outside", "car"},
		usable_with_item = true,
		not_interactive = true,
	},
	{
		id = "backdoor",
		x = 433, y = 254, z = 4,
		req_col_dir = -1,
		dialogue = {"outside", "backdoor"},
	},
	{
		id = "frontdoor",
		x = 299, y = 221, z = 4,
		dialogue = {"outside", "frontdoor_locked"},
		usable_with_item = true,
	},
}

return Data
