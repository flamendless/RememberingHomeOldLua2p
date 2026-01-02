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
		id = "light_switch",
		x = 48, y = 50,
		dialogue = {"utility_room", "light_switch"},
	},

	{
		id = "shelf",
		x = 136, y = 57, z = 4,
		dialogue = {"utility_room", "shelf"},
	},
	{
		id = "electrical_box",
		x = 316, y = 48, z = 4,
		dialogue = {"utility_room", "electrical_box"},
	},
	{
		id = "ironing_board",
		x = 128, y = 69, z = 6,
		scale = 0.75,
		no_col = true,
	},

	{
		id = "washing_machine",
		x = 260, y = 76, z = 4,
		dialogue = {"utility_room", "washing_machine"},
	},
	{
		id = "broom",
		x = 110, y = 60, z = 4,
		no_col = true,
	},

	{
		id = "basket",
		grouped = true,
		dialogue = {"utility_room", "basket"},
		{
			name = "basket_left",
			x = 218, y = 85, z = 4,
		},
		{
			name = "basket_right",
			x = 216, y = 92, z = 5,
			scale = 0.75,
		},
	},

	{
		id = "wood",
		name = "wood1",
		x = 74, y = 96, z = 2,
		no_col = true,
	},
	{
		id = "wood",
		name = "wood2",
		x = 89, y = 96, z = 3,
		no_col = true,
	},
	{
		id = "wood",
		name = "wood3",
		x = 79, y = 79, z = 4,
		no_col = true,
	},
	{
		id = "wood",
		name = "wood4",
		x = 194, y = 96, z = 2,
		no_col = true,
	},
	{
		id = "wood",
		name = "wood5",
		x = 240, y = 96, z = 2,
		no_col = true,
	},
	{
		id = "wood",
		name = "wood6",
		x = 284, y = 96, z = 2,
		no_col = true,
	},
}

return Data
