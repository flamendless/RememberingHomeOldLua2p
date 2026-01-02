local Data = {
	{
		id = "bulb",
		x = 90, y = 16,
		no_col = true,
	},
	{
		id = "bulb",
		name = "bulb2",
		x = 240, y = 16,
		no_col = true,
	},
	{
		id = "left_door",
		x = 16, y = 31, z = 4,
		req_col_dir = -1,
		is_door = true,
	},
	{
		id = "right_door",
		x = 332, y = 47, z = 4,
		req_col_dir = 1,
		is_door = true,
	},
	{
		id = "light_switch",
		x = 64, y = 48,
		dialogue = {"storage_room", "light_switch"},
	},

	{
		id = "ladder",
		x = 97, y = 42, z = 4,
		no_col = true,
	},
	{
		id = "shelf",
		x = 208, y = 52, z = 6,
		dialogue = {"storage_room", "shelf"},
	},
	{
		id = "shelf_side",
		x = 309, y = 42, z = 3,
		no_col = true,
	},
	{
		id = "table",
		x = 102, y = 72, z = 6,
		dialogue = {"storage_room", "table"},
	},
	{
		id = "tires",
		x = 107, y = 91, z = 5,
	},

	{
		id = "filing_cabinet",
		x = 180, y = 68, z = 6,
		dialogue = {"storage_room", "filing_cabinet"},
	},

	{
		id = "barrell",
		x = 76, y = 90, z = 5,
		no_col = true,
	},
	{
		id = "barrell",
		name = "barrell2",
		x = 142, y = 90, z = 4,
		no_col = true,
	},
	{
		id = "barrell",
		name = "barrell3",
		x = 264, y = 90, z = 4,
		no_col = true,
	},
}

return Data
